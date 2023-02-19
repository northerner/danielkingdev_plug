defmodule DanielkingdevPlugTest do
  use ExUnit.Case
  doctest DanielkingdevPlug

  test "greets the world" do
    assert DanielkingdevPlug.hello() == :world
  end
end
