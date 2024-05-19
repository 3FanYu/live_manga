 # lib/crawly_example/books_to_scrape.ex
 defmodule BooksToScrape do
  use Crawly.Spider

  @base_url "https://m.manhuagui.com/comic/43766/627603.html"
  @impl Crawly.Spider
  def base_url(), do: @base_url

  @impl Crawly.Spider
  def init() do
    [start_urls: ["#{@base_url}#p=1"]]
  end

  @impl Crawly.Spider
  def parse_item(response) do
    # Parse response body to document
    {:ok, document} = Floki.parse_document(response.body)
    IO.puts("document: #{inspect(document)}")

    # Create item (for pages where items exists)
    items =
      document
      |> Floki.find("#manga img")
      |> Floki.attribute("src")

    IO.puts("Items: #{inspect(items)}")

      # Extract current page number
    current_page = extract_page_number(response.request.url)

    # Generate the URL for the next page
    next_page_url = "#{@base_url}#p=#{current_page + 1}"
    # Create the next request
    next_requests = [Crawly.Utils.request_from_url(next_page_url)]

    # %Crawly.ParsedItem{items: Enum.map(image_urls, &%{image_url: &1}), requests: next_requests}

    %Crawly.ParsedItem{items: items, requests: next_requests}
  end

  defp extract_page_number(url) do
    url
    |> URI.parse()
    |> Map.get(:fragment)
    |> String.split("=")
    |> List.last()
    |> String.to_integer()
  end

end
