defmodule ExSanity.Query do
  @moduledoc false
  defstruct types: [], preloads: [], filters: [], projections: [], orderings: [], slice: ""

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

  def select(query, fields) do
    %{query | projections: query.projections ++ fields}
  end

  def filter(query, filter) do
    %{query | filters: query.filters ++ [filter]}
  end

  def preload(query, preloads) do
    %{query | preloads: preloads}
  end

  def order(query, order) do
    %{query | orderings: query.orderings ++ [order]}
  end

  def slice(query, slice) do
    %{query | slice: slice}
  end

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
