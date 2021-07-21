defmodule ExSanity.PortableText.Lists do
  def with_list_blocks(blocks) do
    Enum.reduce(blocks, %{blocks: [], path: [-1]}, fn block, acc ->
      handle_block(acc[:blocks], acc[:path], block)
    end)
    |> Access.get(:blocks)
  end

  def get_block_from_path(blocks, path) do
    getters = path |> Enum.reverse() |> path_to_getters()
    get_in(blocks, getters)
  end

  def put_block_in_path(blocks, path, block) do
    case path do
      [] ->
        blocks ++ [block]

      _ ->
        getters = path |> Enum.reverse() |> path_to_getters()
        {_, new} = get_and_update_in(blocks, getters, &{&1, &1 ++ [block]})
        new
    end
  end

  def path_to_getters(path) do
    Enum.map(path, fn point ->
      case point do
        key when is_binary(key) -> key
        int when is_integer(int) -> Access.at(int)
      end
    end)
  end

  # List block we're currently iterating through.
  def handle_block(blocks, path = [_iter, "children" | _], block = %{"listItem" => _listItem}) do
    prev_block = get_block_from_path(blocks, path)

    cond do
      # If the block is a sibling block, push it to the end
      # of our current list, and increment our path.
      block["level"] === prev_block["level"] ->
        push_block_to_end_of_path(blocks, path, block)

      # If the block is a child block, create a new list and
      # navigate our path into the new list block.
      block["level"] > prev_block["level"] ->
        list_block = create_list_block(block)

        new_blocks =
          put_block_in_path(blocks, ["children" | path], list_block)

        %{
          blocks: new_blocks,
          path: [0, "children", 1, "children" | path]
        }

      # If the block is a parent block, jump the path
      # back up the tree to the parent list and push our
      # block in place.
      block["level"] < prev_block["level"] ->
        block_depth_difference = prev_block["level"] - block["level"]
        [iter | rest] = Enum.drop(path, 4 * block_depth_difference)
        new_blocks = put_block_in_path(blocks, rest, block)

        %{
          blocks: new_blocks,
          path: [iter + 1 | rest]
        }

      # If the previous block was not a list at all,
      # create a new list block and navigate the path
      # into it.
      prev_block["level"] == nil ->
        create_new_list_block(blocks, path, block)
    end
  end

  # New list block
  #
  # We create a new list block, push it to the end of the blocks list
  # and navigate our path into the new list block.
  def handle_block(blocks, path, block = %{"listItem" => _listItem}) do
    create_new_list_block(blocks, path, block)
  end

  # Non list block
  #
  # We simply push our block to the end of the blocks list
  # and increment our path.
  def handle_block(blocks, path, block) do
    push_block_to_end_of_list(blocks, path, block)
  end

  def push_block_to_end_of_path(blocks, path = [iter | rest], block) do
    %{
      blocks: put_block_in_path(blocks, Enum.drop(path, 1), block),
      path: [iter + 1 | rest]
    }
  end

  def push_block_to_end_of_list(blocks, path, block) do
    %{
      blocks: blocks ++ [block],
      path: [List.last(path) + 1]
    }
  end

  def create_new_list_block(blocks, [iter | rest] = path, block) do
    list_block = create_list_block(block)
    new_blocks = put_block_in_path(blocks, Enum.drop(path, 1), list_block)

    %{
      blocks: new_blocks,
      path: [0, "children" | [iter + 1 | rest]]
    }
  end

  def create_list_block(block) do
    %{
      "_type" => "list",
      "_key" => "#{block["_key"]}-parent",
      "level" => block["level"],
      "listItem" => block["listItem"],
      "children" => [block],
      "markDefs" => block["markDefs"]
    }
  end
end
