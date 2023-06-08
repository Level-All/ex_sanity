defmodule ExSanity.CMS do
  @moduledoc """
  Inspired by Ecto.Repo. Runs queries against the Sanity CMS and returns the
  result.

  Currently only supports "read" type queries. Create/update queries are on
  the roadmap.
  """
  alias ExSanity.Client
  alias ExSanity.Query

  def get(query, id) do
    query_string = Query.build(query, id)

    {:ok, response} = Client.query(query_string)

    [document | _] = response.body["result"]

    document
  end

  def one(query) do
    query_string = Query.build(query)

    {:ok, response} = Client.query(query_string)

    [document | _] = response.body["result"]

    document
  end

  def all(query) do
    query_string = Query.build(query)

    {:ok, response} = Client.query(query_string)

    response.body["result"]
  end
end
