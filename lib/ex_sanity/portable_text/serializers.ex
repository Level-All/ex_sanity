defmodule ExSanity.PortableText.Serializers do
  use PhoenixHTMLHelpers

  alias ExSanity.PortableText.{Utils}

  @default_marks ["strong", "em", "code", "underline", "strike-through"]

  def get_serializer(serializers, keys), do: get_in(serializers, keys)

  def serializers(options \\ %{}) do
    %{
      span: fn serializers, block, mark_defs -> span_serializer(serializers, block, mark_defs) end,
      list: fn serializers, block, _mark_defs -> list_serializer(serializers, block) end,
      block: fn serializers, block, _mark_defs -> block_serializer(serializers, block) end,
      list_item: fn serializers, block, _mark_defs -> list_item_serializer(serializers, block) end,
      image: fn _serializers, block, _mark_defs -> image_serializer(block, options) end,
      marks: %{
        link: fn _serializers, block, mark_defs -> link_serializer(block, mark_defs) end
      }
    }
  end

  def span_serializer(_serializers, %{"text" => text, "marks" => []}, _mark_defs) do
    text
  end

  def span_serializer(serializers, %{"text" => text, "marks" => marks}, mark_defs) do
    render_marks_map(serializers, marks, mark_defs) |> render_nested_marks(text)
  end

  def list_serializer(serializers, %{
        "children" => children,
        "markDefs" => mark_defs,
        "listItem" => list_item
      }) do
    content_tag(
      Utils.list_item_to_atom(list_item),
      render_children(serializers, children, mark_defs)
    )
  end

  def list_item_serializer(serializers, %{"children" => children, "markDefs" => mark_defs}) do
    content_tag(:li, render_children(serializers, children, mark_defs))
  end

  def block_serializer(serializers, %{
        "_type" => "block",
        "children" => children,
        "markDefs" => mark_defs,
        "style" => style
      }) do
    content_tag(Utils.style_to_atom(style), render_children(serializers, children, mark_defs))
  end

  def image_serializer(source, options \\ %{})

  def image_serializer(source = %{"asset" => %{"_id" => _id}}, options) do
    %{source: source}
    |> Map.merge(parse_image_options(options[:image_options]))
    |> ExSanity.Assets.url_for_image!()
    |> img_tag()
  end

  def image_serializer(source = %{"asset" => %{"_ref" => _id}}, options) do
    %{source: source}
    |> Map.merge(parse_image_options(options[:image_options]))
    |> ExSanity.Assets.url_for_image!()
    |> img_tag()
  end

  def image_serializer(source = %{"asset" => %{"url" => _url}}, options) do
    %{source: source}
    |> Map.merge(parse_image_options(options[:image_options]))
    |> ExSanity.Assets.url_for_image!()
    |> img_tag()
  end

  def parse_image_options(nil), do: %{}

  def parse_image_options(opts), do: opts

  def link_serializer(mark_def, content) do
    content_tag(:a, content, href: mark_def["href"])
  end

  def render_children(serializers, children, mark_defs) do
    Enum.map(children, fn child ->
      ExSanity.PortableText.render_node(serializers, child, mark_defs)
    end)
  end

  # Generates a map of anonymous functions which
  # return a content_tag with a specified tag
  # and content argument.
  # This map can be reduced to generate nested marks (e.g. <ul><b>...</b></ul>)
  def render_marks_map(serializers, marks, mark_defs) do
    Enum.map(marks, fn mark ->
      fn content -> render_mark(serializers, mark, mark_defs, content) end
    end)
  end

  # Takes a map of anonymous functions which return a content_tag
  def render_nested_marks(map, text) do
    Enum.reduce(map, text, fn func, acc -> acc |> func.() end)
  end

  # Renders a content_tag with atom, and content
  def render_mark(serializers, mark, mark_defs, content) do
    if Enum.member?(@default_marks, mark) do
      content_tag(Utils.mark_to_atom(mark), content)
    else
      case Enum.find(mark_defs, fn mark_def -> mark_def["_key"] == mark end) do
        nil -> render_custom_mark(serializers, mark, content)
        mark_def -> render_custom_mark(serializers, mark_def, content)
      end
    end
  end

  def render_custom_mark(serializers, mark_def = %{"_type" => type}, content) do
    mark_serializers = serializers[:marks]
    type_as_atom = String.to_atom(type)

    if Map.has_key?(mark_serializers, type_as_atom) do
      mark_serializers[type_as_atom].(serializers, mark_def, content)
    else
      raise "a custom serializer for type: #{type} could not be found"
    end
  end

  def render_custom_mark(serializers, mark, content) do
    mark_serializers = serializers[:marks]
    type_as_atom = String.to_atom(mark)

    if Map.has_key?(mark_serializers, type_as_atom) do
      mark_serializers[type_as_atom].(serializers, mark, content)
    else
      raise "a custom serializer for mark: #{mark} could not be found"
    end
  end
end
