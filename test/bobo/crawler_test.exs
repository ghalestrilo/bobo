defmodule Bobo.CrawlerTest do
  use ExUnit.Case

  describe "get_links/2" do
    test "returns a list of links" do
      links =
        "<a href=\"http://example.com\">Example</a>"
        |> Bobo.Crawler.get_links("http://olhardigital.com.br")

      assert links == ["http://example.com"]
    end
  end

  describe "apply_prefix/2" do
    test "returns the url with the prefix" do
      assert Bobo.Crawler.apply_prefix("/example", "http://olhardigital.com.br") ==
               "http://olhardigital.com.br/example"
    end

    test "returns the url without the prefix" do
      assert Bobo.Crawler.apply_prefix("http://example.com", "http://olhardigital.com.br") ==
               "http://example.com"
    end
  end

  describe "count_ads/1" do
    test "returns the number of ads" do
      ads =
        ~s{<div class="ad-adzep-billboard"></div><span class="autozep-div"></span>}
        |> Bobo.Crawler.count_ads()

      assert ads == 2
    end

    test "buzzfeed has a lot of ads!" do
      ads =
        File.read!("test/fixtures/buzzfeed.html")
        |> Bobo.Crawler.count_ads()

      assert ads == 20
    end
  end
end
