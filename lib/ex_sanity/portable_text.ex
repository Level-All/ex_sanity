defmodule ExSanity.PortableText do
  import Phoenix.HTML.Tag

  alias ExSanity.PortableText.{Serializers, Lists}

  def to_html(nodes, custom_serializers \\ %{}) do
    base_serializers = Serializers.serializers()
    serializers = merge_serializers(base_serializers, custom_serializers)

    render_container(nodes |> Lists.with_list_blocks() |> Enum.map(fn node -> render_node(serializers, node) end))
  end

  def render_container(children) do
    content_tag(:div, children)
  end

  def render_node(
    serializers,
     node = %{
       "markDefs" => mark_defs
     }
   ), do: match_node(serializers, node, mark_defs)

  def render_node(serializers, node, mark_defs \\ []), do: match_node(serializers, node, mark_defs)

  defp match_node(serializers, node, mark_defs) do
    case node do
      %{"_type" => "list"} -> serializers[:list].(serializers, node, mark_defs)
      %{"_type" => "span"} -> serializers[:span].(serializers, node, mark_defs)
      %{"_type" => "block", "children" => _, "listItem" => _} -> serializers[:list_item].(serializers, node, mark_defs)
      %{"_type" => "block"} -> serializers[:block].(serializers, node, mark_defs)
      %{"_type" => "image"} -> serializers[:image].(serializers, node, mark_defs)
      %{"_type" => type} -> serializers[String.to_atom(type)].(serializers, node, mark_defs)
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
