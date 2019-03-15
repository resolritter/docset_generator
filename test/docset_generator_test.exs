defmodule DocsetGeneratorTest do
  use ExUnit.Case
  doctest DocsetGenerator

  test "greets the world" do
    assert DocsetGenerator.hello() == :world
  end
end
