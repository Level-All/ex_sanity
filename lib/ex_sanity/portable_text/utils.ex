defmodule ExSanity.PortableText.Utils do
  # Maps style tag to
  # valid atom for content_tag
  def style_to_atom(style) do
    case style do
      "normal" -> :p
      _ -> String.to_atom(style)
    end
  end

  # Maps list_item string to valid
  # atom for content_tag
  def list_item_to_atom(list_item) do
    if list_item == "bullet", do: :ul, else: :ol
  end

  # Maps standard mark to
  # valid atom for content_tag
  def mark_to_atom(mark) do
    case mark do
      "strike-through" -> :s
      "underline" -> :u
      "strong" -> :b
      _ -> String.to_atom(mark)
    end
  end
end
