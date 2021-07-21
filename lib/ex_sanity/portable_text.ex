defmodule ExSanity.PortableText do
  import Phoenix.HTML.Tag

  alias ExSanity.PortableText.{Serializers, Lists}

  def to_html(nodes \\ []) do
    render_container(nodes |> Lists.with_list_blocks() |> Enum.map(fn node -> render_node(node) end))
  end

  def render_container(children) do
    content_tag(:div, children)
  end

  def render_node(
     node = %{
       "mark_defs" => mark_defs
     }
   ), do: match_node(node, mark_defs)

  def render_node(node, mark_defs \\ []), do: match_node(node, mark_defs)

  defp match_node(node, mark_defs) do
    case node do
      %{"_type" => "list"} -> Serializers.get_serializer([:list]).(node)
      %{"_type" => "span"} -> Serializers.get_serializer([:span]).(node, mark_defs)
      %{"_type" => "block", "children" => _, "listItem" => _} -> Serializers.get_serializer([:list_item]).(node)
      %{"_type" => "block"} -> Serializers.get_serializer([:block]).(node)
      %{"_type" => type} -> Serializers.get_serializer([String.to_atom(type)]).(node)
    end
  end
end
