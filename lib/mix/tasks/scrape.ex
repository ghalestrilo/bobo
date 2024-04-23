defmodule Mix.Tasks.Scrape do
  @moduledoc "The hello mix task: `mix help hello`"
  use Mix.Task
  alias Bobo.Crawler

  @defaultsite "https://olhardigital.com.br/2024/04/11/pro/teorico-da-computacao-recebe-o-premio-turing-de-us-1-milhao/"

  @shortdoc "Simply calls scrape/1 with each passed arg as a URL"
  def run(args \\ [@defaultsite]) do
    HTTPoison.start()

    for url <- args do
      scrape(url, 2)
    end
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
    :ok
  end

  def scrape([], _level) do
    :ok
  end

  def scrape(url, level) do
    IO.puts("Scraping #{url}...")

    with {:ok, %HTTPoison.Response{body: body, status_code: 200}} <-
           HTTPoison.get(url, timeout: 10_000),
         {:ok, doc} <- Floki.parse_document(body) do
      # IO.inspect(body)
      links = Crawler.get_links(doc, url)
      link_count = Enum.count(links)
      ad_count = Crawler.count_ads(doc)
      IO.inspect("ads: #{ad_count} | links: #{link_count} | #{url}")

      links
      |> Enum.map(fn link ->
        # Task.start(fn -> scrape(link, level - 1) end)
        scrape(link, level - 1)
      end)
      |> Enum.all?(fn
        {:ok, _} -> true
        _ -> false
      end)
      |> case do
        true -> :ok
        false -> :error
      end
    end

    # |> IO.inspect()

    # case HTTPoison.get(url) do
    #   {:ok, %HTTPoison.Response{body: body}} ->
    #   {:error, %HTTPoison.Error{reason: reason}} ->
    #     IO.puts("Failed to fetch #{url}: #{reason}")
    # end
  end
end
