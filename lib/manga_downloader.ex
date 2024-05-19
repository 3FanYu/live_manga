defmodule MangaDownloader do
  @moduledoc """
  A script to download all pages of a manga from a given URL.
  """

  def run(url) do
    url
    |> fetch_page()
    |> case do
      {:ok, html} ->
        IO.puts("Successfully fetched the page")
        base_url = URI.parse(url) |> Map.put(:path, "") |> URI.to_string()
        html |> extract_image_urls(base_url) |> download_images()
      {:error, reason} -> IO.puts("Failed to fetch the page: #{reason}")
    end
  end

  defp fetch_page(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> {:ok, body}
      {:ok, %HTTPoison.Response{status_code: status}} -> {:error, "HTTP status #{status}"}
      {:error, %HTTPoison.Error{reason: reason}} -> {:error, reason}
    end
  end

  defp extract_image_urls(html, base_url) do
    case Floki.parse_document(html) do
      {:ok, document} ->
        IO.puts("Successfully parsed the HTML")

        # Print the parsed document for debugging
        IO.inspect(document, label: "Parsed Document")

        # Find the manga div and print it for debugging
        manga_div = Floki.find(document, "#manga")
        IO.inspect(manga_div, label: "Manga Div")

        image_urls = manga_div
        |> Floki.find("img")
        |> Floki.attribute("src")
        |> Enum.map(&make_absolute_url(&1, base_url))

        IO.inspect(image_urls, label: "Extracted image URLs")
        image_urls

      {:error, reason} ->
        IO.puts("Failed to parse HTML: #{reason}")
        []
    end
  end

  defp make_absolute_url(url, base_url) when is_binary(url) do
    if URI.parse(url).host do
      url
    else
      URI.merge(base_url, url) |> to_string()
    end
  end

  defp download_images(image_urls) do
    Enum.each(image_urls, fn url ->
      IO.puts("Downloading image: #{url}")
      case HTTPoison.get(url) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          filename = Path.basename(url)
          File.write!("images/#{filename}", body)
          IO.puts("Downloaded #{filename}")

        {:ok, %HTTPoison.Response{status_code: status}} ->
          IO.puts("Failed to download #{url}. Status code: #{status}")

        {:error, %HTTPoison.Error{reason: reason}} ->
          IO.puts("Failed to download #{url}. Reason: #{reason}")
      end
    end)
  end
end

