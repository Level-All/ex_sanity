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

  @default_options [method: :get]

  def query(query, opts \\ @default_options) do
    method = opts[:method]
    params = make_params(query, method)
    body = make_body(query, method)
    headers = headers()
    {_, options} = Keyword.split(opts, [:method])

    request(%HTTPoison.Request{
      method: method,
      url: "",
      body: body,
      params: params,
      headers: headers,
      options: options
    })
    |> handle_response()
  end

  defp make_params(query, :get), do: %{query: query}

  defp make_params(_query, :post), do: nil

  defp make_body(_query, :get), do: ""

  defp make_body(query, :post), do: %{query: query}

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
