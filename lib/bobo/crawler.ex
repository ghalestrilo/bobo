defmodule Bobo.Crawler do
  @ad_classes [
    "ad-adzep-billboard",
    "autozep-div",
    "autozep-measure"
  ]
  @ad_ids [
    ~r/Ad/,
    ~r/Ad--promo-infinite/,
    ~r/Ad--sidebar/,
    ~r/Ad--loading/,
    ~r/ad_unit/,
    ~r/ad-tb/,
    ~r/ad-(bottom|inline|sidebar)-([0-9]+|infinite)/,
    ~r/ad_leaderboard_footer/,
    ~r/ad_right_rail_repeating/,
    ~r/ad-tb/,
    ~r/footer/,
    ~r/ad_leaderboard_footer/
  ]

  @ad_hrefs [
    "https://c.amazon-adsystem.com"
  ]

  def get_links(doc, url) do
    doc
    |> Floki.find("a")
    |> Enum.filter(&(not is_nil(&1)))
    |> Enum.map(fn link ->
      link
      |> Floki.attribute("href")
      |> Enum.at(0)
      |> apply_prefix(url)
    end)
    |> Enum.filter(fn
      nil ->
        false

      link ->
        link
        |> String.starts_with?("http")

        # |> String.starts_with?("javascript:")
        # |> Kernel.not()
    end)
  end

  def apply_prefix("//" <> _, _), do: nil
  def apply_prefix("/" <> rest, url), do: url <> "/" <> rest
  def apply_prefix(url, _), do: url

  def count_ads(doc) do
    (Floki.find(doc, "div") ++
       Floki.find(doc, "span") ++
       Floki.find(doc, "link"))
    |> Enum.filter(&is_ad_tag?/1)
    |> Enum.count()
  end

  @doc "in the future, compile a list of ad tags into a regex for performance"
  def is_ad_tag?(tag) do
    has_ad_class?(tag) || has_ad_id?(tag) || has_id_href?(tag)
  end

  def has_ad_class?(tag) do
    @ad_classes
    |> Enum.any?(fn class ->
      tag
      |> Floki.attribute("class")
      |> to_string()
      |> String.contains?(class)
    end)
  end

  def has_ad_id?(tag) do
    @ad_ids
    |> Enum.any?(fn ad_id ->
      Floki.attribute(tag, "id")
      |> to_string()
      |> then(&Regex.match?(ad_id, &1))
      |> dbg
    end)
  end

  def has_id_href?(tag) do
    @ad_hrefs
    |> Enum.any?(fn ad_href ->
      tag
      |> Floki.attribute("href")
      |> Enum.member?(ad_href)
    end)
  end
end
