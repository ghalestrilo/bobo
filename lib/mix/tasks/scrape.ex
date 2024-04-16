defmodule Mix.Tasks.Scrape do
  @moduledoc "The hello mix task: `mix help hello`"
  use Mix.Task

  @adclasses [
    "ad-adzep-billboard",
    "autozep-div",
    "autozep-measure"
  ]

  @defaultsite "https://olhardigital.com.br/2024/04/11/pro/teorico-da-computacao-recebe-o-premio-turing-de-us-1-milhao/"

  @shortdoc "Simply calls scrape/1 with each passed arg as a URL"
  def run(args \\ [@defaultsite]) do
    HTTPoison.start()

    for url <- args do
      # Task.start(fn ->  end)
      scrape(url, 2)
    end

    # |> Task.await_many()
  end

  @doc """
  This method uses floki and HTTPoison to scrape a website.
  It receives an URL and the maximum level of recursion to scrape.
  It loads the page, parses it with Floki, and prints the title.
  Next, it finds all the links in the page and prints them.
  Finally, it recursively calls itself for each link found.
  It stops once it reaches the maximum level of recursion.
  """
  def scrape(_url, 0) do
    # IO.puts("Reached maximum recursion level.")
    :ok
  end

  def scrape(url, level) do
    IO.puts("Scraping #{url}...")

    with {:ok, %HTTPoison.Response{body: body}} <- HTTPoison.get(url),
         {:ok, doc} <- Floki.parse_document(body) do
      links =
        Floki.find(doc, "a")
        |> Enum.filter(fn link ->
          link
          |> Floki.attribute("href")
          |> Enum.at(0)
          |> String.starts_with?("javascript:")
          |> Kernel.not()
        end)

      link_count =
        links
        |> Enum.count()

      # |> IO.inspect(label: "links")

      ad_count =
        doc
        |> count_ads()

      # |> IO.inspect(label: "ads")

      links
      |> Enum.map(&Floki.attribute(&1, "href"))
      |> Enum.map(fn link ->
        # scrape(link, level - 1)
        # Task.start(fn -> scrape(link, level - 1) end)
        IO.inspect("ads: #{ad_count} | links: #{link_count} | #{link}")
        scrape(link, level - 1)
      end)

      # |> Task.await_many()
    end

    # case HTTPoison.get(url) do
    #   {:ok, %HTTPoison.Response{body: body}} ->
    #   {:error, %HTTPoison.Error{reason: reason}} ->
    #     IO.puts("Failed to fetch #{url}: #{reason}")
    # end
  end

  def count_ads(doc) do
    (Floki.find(doc, "div") ++ Floki.find(doc, "span"))
    |> Enum.filter(&is_ad_tag/1)
    |> Enum.count()
  end

  def is_ad_tag(tag) do
    @adclasses
    |> Enum.filter(fn class ->
      tag
      |> Floki.attribute("class")
      |> to_string()
      |> String.contains?(class)
    end)
    |> Enum.count()
    |> Kernel.>(0)
  end
end
