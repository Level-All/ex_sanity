defmodule ExSanity.Client do
  use HTTPoison.Base

  def project_id, do: ExSanity.Config.resolve(:project_id)
  def dataset, do: ExSanity.Config.resolve(:dataset)
  def api_key, do: ExSanity.Config.resolve(:api_key)
  def version, do: ExSanity.Config.resolve(:version)
  def endpoint, do: ExSanity.Config.resolve(:endpoint)

  def root_url,
    do: "https://#{project_id()}.#{endpoint()}.sanity.io/#{version()}/data/query/#{dataset()}"

  def headers,
    do: %{
      Authorization: "Bearer #{api_key()}"
    }

  def query(query) do
    ("?" <> URI.encode_query(%{query: query}))
    |> get(headers())
    |> handle_response()
  end

  def query(query, method: :post) do
    post("", %{query: query}, headers())
    |> handle_response()
  end

  def handle_response(response) do
    case response do
      {:ok, %HTTPoison.Response{body: {:error, :could_not_parse}, status_code: status}} ->
        {:error, %{code: status, message: "Failed to parse response body as JSON"}}

      {:ok, %HTTPoison.Response{body: body, status_code: 200}} ->
        {:ok, body}

      {:ok, %HTTPoison.Response{body: %{"message" => message}, status_code: status}} ->
        {:error, %{code: status, message: message}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def process_request_url(url), do: root_url() <> url

  def process_request_body(body), do: body |> Jason.encode!()

  def process_response_body(body) do
    if body == "" do
      %{}
    else
      case Jason.decode(body) do
        {:ok, body} ->
          body

        _ ->
          {:error, :could_not_parse}
      end
    end
  end
end
