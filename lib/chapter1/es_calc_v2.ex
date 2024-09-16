defmodule Chapter1.EsCalcV2 do
  def handle_command(%{value: _value}, %{command: :add, value: v}) do
    %{event_type: :value_added, value: v}
  end

  def handle_command(%{value: _value}, %{command: :subtract, value: v}) do
    %{event_type: :value_subtracted, value: v}
  end

  def handle_command(%{value: _value}, %{command: :multiply, value: v}) do
    %{event_type: :value_multiplied, value: v}
  end

  def handle_command(%{value: _value}, %{command: :divide, value: v}) do
    %{event_type: :value_divided, value: v}
  end

  def handle_event(%{value: value}, %{event_type: :value_added, value: v}) do
    %{value: value + v}
  end

  def handle_event(%{value: value}, %{event_type: :value_subtracted, value: v}) do
    %{value: value - v}
  end

  def handle_event(%{value: value}, %{event_type: :value_multiplied, value: v}) do
    %{value: value * v}
  end

  def handle_event(%{value: value}, %{event_type: :value_divided, value: v}) do
    %{value: value / v}
  end
end
