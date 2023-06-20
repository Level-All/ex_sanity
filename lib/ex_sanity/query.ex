defmodule ExSanity.Query do
  @moduledoc """
  Use an Ecto-like DSL to build GROQ queries for the Sanity API.
  """
  defstruct types: [], preloads: [], filters: [], projections: [], orderings: [], slice: ""

  @doc """
  Takes a single or list of Sanity document types to query. You can pass an `"*"`
  if you want to query all document types.

  Examples:

  from("*") // all document types
  from(:movie) // movie documents
  from([:movie, :person]) // movie OR person documents
  """
  def from(type) when is_atom(type) do
    %__MODULE__{
      types: [type]
    }
  end

  def from(types) do
    %__MODULE__{
      types: types
    }
  end

  @doc """
  Allows you to specify the fields on the document you would like to be returned from the query.

  Takes a list of atom keys of the fields you would like to select.

  Examples:

  select(query, [:description])
  """
  def select(query, fields) do
    %{query | projections: query.projections ++ fields}
  end

  @doc """
  Allows you to specify criteria to filter documents by.

  Takes a string specifying the filter to be applied.

  Examples:

  filter(query, ~s(slug.current == "some-slug"))
  """
  def filter(query, filter) do
    %{query | filters: query.filters ++ [filter]}
  end

  @doc """
  Load referenced documents as part of the query.

  Takes a list of documents to preload.

  Example:

  preload(query, [:tags, :resources])
  """
  def preload(query, preloads) do
    %{query | preloads: preloads}
  end

  @doc """
  Adds a sort order to the query.

  Takes a tuple with the field to be sorted on and the direction.

  Examples:

  order(query, {:_createdAt, :asc})
  order(query, {:releaseDate, :desc})
  """
  def order(query, order) do
    %{query | orderings: query.orderings ++ [order]}
  end

  @doc """
  Specify a subset of the result set you would like returned.

  Takes a string specifying the slice you'd like.

  Examples:

  slice(query, "0")
  slice(query, "0..5")
  slice(query, "0...10")
  """
  def slice(query, slice) do
    %{query | slice: slice}
  end

  @doc """
  Builds the given query into a GROQ query string which can be sent to the Sanity API.

  You can pass on optional `id` string as the second parameter as a convenience for
  selecting specific documents.
  """
  def build(query, id) do
    query = filter(query, ~s(_id == "#{id}"))
    build(query)
  end

  def build(%{types: types, filters: [], orderings: [], slice: "", projections: [], preloads: []}) do
    ~s(*[#{build_types(types)}])
  end

  def build(%{types: "*", filters: filters}) do
    ~s(*[#{build_filters(filters)}])
  end

  def build(%{
        types: types,
        filters: filters,
        orderings: [],
        slice: "",
        projections: [],
        preloads: []
      }) do
    ~s(*[#{build_types(types)}#{build_filters(filters)}])
  end

  def build(%{
        types: types,
        filters: filters,
        orderings: orderings,
        slice: slice,
        projections: [],
        preloads: []
      }) do
    ~s(*[#{build_types(types)}#{build_filters(filters)}]#{build_orderings(orderings)}#{build_slice(slice)})
  end

  def build(query) do
    ~s(*[#{build_types(query.types)}#{build_filters(query.filters)}]#{build_orderings(query.orderings)}#{build_slice(query.slice)}{#{build_projections(query.projections)}#{build_preloads(query.preloads)}})
  end

  defp build_types("*"), do: ""

  defp build_types([type]) do
    ~s(_type == "#{type}")
  end

  defp build_types(types) do
    ~s(_type in ["#{Enum.join(types, "\", \"")}"])
  end

  defp build_filters([filter]) do
    ~s(#{filter})
  end

  defp build_filters(filters) do
    Enum.reduce(filters, "", fn filter, acc ->
      acc <> ~s( && #{filter})
    end)
  end

  defp build_projections(projections) do
    Enum.join(projections, ", ")
  end

  defp build_preloads(preloads) do
    Enum.reduce(preloads, "", fn preload, acc ->
      acc <> ~s(, #{Atom.to_string(preload)}[]->)
    end)
  end

  defp build_orderings(orderings) do
    Enum.reduce(orderings, "", fn {field, direction}, acc ->
      acc <> ~s( | order(#{field} #{Atom.to_string(direction)}\))
    end)
  end

  defp build_slice(""), do: ""

  defp build_slice(slice) do
    ~s([#{slice}])
  end
end
