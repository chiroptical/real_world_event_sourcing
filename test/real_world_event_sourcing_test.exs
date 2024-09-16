defmodule RealWorldEventSourcingTest do
  use ExUnit.Case
  doctest RealWorldEventSourcing

  test "greets the world" do
    assert RealWorldEventSourcing.hello() == :world
  end
end
