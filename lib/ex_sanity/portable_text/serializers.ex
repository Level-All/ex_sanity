defmodule ExSanity.PortableText.Serializers do
  import Phoenix.HTML.Tag

  alias ExSanity.PortableText.{Utils}

  @default_marks ["strong", "em", "code", "underline", "strike-through"]

  def get_serializer(keys), do: get_in(serializers(), keys)

  defp serializers do
    %{
      span: fn block, mark_defs -> span_serializer(block, mark_defs) end,
      list: fn block -> list_serializer(block) end,
      block: fn block -> block_serializer(block) end,
      list_item: fn block -> list_item_serializer(block) end,
      image: fn block -> image_serializer(block) end,
      ##
      # Custom block serializers can be configured here
      ##
      marks: %{
        link: fn block, mark_defs -> link_serializer(block, mark_defs) end
        ##
        # Custom mark serializers can be configured here
        ##
      }
    }
  end

  def span_serializer(%{"text" => text, "marks" => []}, _mark_defs) do
    text
  end

  def span_serializer(%{"text" => text, "marks" => marks}, mark_defs) do
    render_marks_map(marks, mark_defs) |> render_nested_marks(text)
  end

  def list_serializer(%{"children" => children, "mark_defs" => mark_defs, "listItem" => list_item}) do
    content_tag(Utils.list_item_to_atom(list_item), render_children(children, mark_defs))
  end

  def list_item_serializer(%{"children" => children, "mark_defs" => mark_defs}) do
    content_tag(:li, render_children(children, mark_defs))
  end

  def block_serializer(%{"_type" => "block", "children" => children, "mark_defs" => mark_defs, "style" => style}) do
    content_tag(Utils.style_to_atom(style), render_children(children, mark_defs))
  end

  def image_serializer(asset = %{"asset" => %{"_ref" => _ref}}) do
    url = ExSanity.AssetBuilder.build_image_url(asset)
    img_tag(url)
  end

  def image_serializer(%{"asset" => %{"url" => url}}) do
    img_tag(url)
  end

  def link_serializer(mark_def, content) do
    content_tag(:a, content, href: mark_def["href"])
  end

  def render_children(children, mark_defs) do
    Enum.map(children, fn child -> ExSanity.PortableText.render_node(child, mark_defs) end)
  end

  # Generates a map of anonymous functions which
  # return a content_tag with a specified tag
  # and content argument.
  # This map can be reduced to generate nested marks (e.g. <ul><b>...</b></ul>)
  def render_marks_map(marks, mark_defs) do
    Enum.map(marks, fn mark -> (fn content -> render_mark(mark, mark_defs, content) end) end)
  end

  # Takes a map of anonymous functions which return a content_tag
  def render_nested_marks(map, text) do
    Enum.reduce(map, text, fn func, acc -> acc |> func.() end)
  end

  # Renders a content_tag with atom, and content
  def render_mark(mark, mark_defs, content) do
    if Enum.member?(@default_marks, mark) do
      content_tag(Utils.mark_to_atom(mark), content)
    else
      mark_def = Enum.find(mark_defs, fn mark_def -> mark_def["_key"] == mark end)
      render_custom_mark(mark_def, content)
    end
  end

  def render_custom_mark(mark_def = %{"_type" => type}, content) do
    mark_serializers = get_serializer([:marks])
    type_as_atom = String.to_atom(type)

    if Map.has_key?(mark_serializers, type_as_atom) do
      get_serializer([:marks, type_as_atom]).(mark_def, content)
    else
      raise "a custom serializer for type: #{type} could not be found"
    end
  end
end
