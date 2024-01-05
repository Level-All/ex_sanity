defmodule ExSanity.PortableText do
  use PhoenixHTMLHelpers

  alias ExSanity.PortableText.{Serializers, Lists}

  def to_html(nodes, options \\ %{}) do
    base_serializers = Serializers.serializers(options)

    serializers =
      if options[:serializers] do
        merge_serializers(base_serializers, options[:serializers])
      else
        base_serializers
      end

    nodes
    |> Lists.with_list_blocks()
    |> Enum.map(fn node -> render_node(serializers, node) end)
    |> render_container(options[:container])
  end

  def render_container(children, _container = nil), do: content_tag(:div, children)
  def render_container(children, _container = false), do: children
  def render_container(children, container) when is_function(container), do: container.(children)

  def render_node(
        serializers,
        node = %{
          "markDefs" => mark_defs
        }
      ),
      do: match_node(serializers, node, mark_defs)

  def render_node(serializers, node, mark_defs \\ []),
    do: match_node(serializers, node, mark_defs)

  defp match_node(serializers, node, mark_defs) do
    case node do
      %{"_type" => "list"} ->
        serializers[:list].(serializers, node, mark_defs)

      %{"_type" => "span"} ->
        serializers[:span].(serializers, node, mark_defs)

      %{"_type" => "block", "children" => _, "listItem" => _} ->
        serializers[:list_item].(serializers, node, mark_defs)

      %{"_type" => "block"} ->
        serializers[:block].(serializers, node, mark_defs)

      %{"_type" => "image"} ->
        serializers[:image].(serializers, node, mark_defs)

      %{"_type" => type} ->
        type_as_atom = String.to_atom(type)

        if Map.has_key?(serializers, type_as_atom) do
          serializers[type_as_atom].(serializers, node, mark_defs)
        else
          {:safe, []}
        end
    end
  end

  defp merge_serializers(base_serializers, custom_serializers) do
    Map.merge(base_serializers, custom_serializers, &resolve_serializers/3)
  end

  defp resolve_serializers(key, serializer_val, custom_val) do
    case key do
      :marks ->
        Map.merge(serializer_val, custom_val)

      _ ->
        custom_val
    end
  end
end
