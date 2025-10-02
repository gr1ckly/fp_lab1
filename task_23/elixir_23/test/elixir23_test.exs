defmodule Elixir23Test do
  use ExUnit.Case
  alias Elixir23.{MapRealization, ModuleRealization, Recursion, StreamRealization, TailRecursion}

  @expected_sum 4_179_871

  test "TailRecursion.count" do
    assert TailRecursion.count() == @expected_sum
  end

  test "Recursion.count" do
    assert Recursion.count() == @expected_sum
  end

  test "ModuleRealization.count" do
    assert ModuleRealization.count() == @expected_sum
  end

  test "MapRealization.count" do
    assert MapRealization.count() == @expected_sum
  end

  test "StreamRealization.count" do
    assert StreamRealization.count() == @expected_sum
  end
end
