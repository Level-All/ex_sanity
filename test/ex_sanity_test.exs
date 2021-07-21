defmodule ExSanityTest do
  use ExUnit.Case
  doctest ExSanity

  test "greets the world" do
    assert ExSanity.hello() == :world
  end
end
