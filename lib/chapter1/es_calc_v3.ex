defmodule Chapter1.EsCalcV3 do
  @max_state_value 10_000
  @min_state_value 0

  def handle_command(%{value: value}, %{command: :add, value: v}) do
    %{event_type: :value_added, value: min(@max_state_value - value, v)}
  end

  def handle_command(%{value: value}, %{command: :subtract, value: v}) do
    %{event_type: :value_subtracted, value: max(@min_state_value, value - v)}
  end

  def handle_command(%{value: value}, %{command: :multiply, value: v})
      when value * v > @max_state_value do
    {:error, :multiplication_failed}
  end

  def handle_command(%{value: _value}, %{command: :multiply, value: v}) do
    %{event_type: :value_multiplied, value: v}
  end

  # Rule: all events are immutable and in the past
  # Every event represents something that actually happened
  # Modeling the absence of a thing or something that never occurred is often
  # confusing to developers and event processors.
  def handle_command(%{value: _value}, %{command: :divide, value: v})
      when v == 0 do
    {:error, :division_by_zero}
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

  # This would accept {:error, ...} and simply return the state
  # Rule: Any attempt to apply bad, unexpected, or explicitly modeled failure
  # event to an existing state must always return the existing state.
  def handle_event(%{value: _value} = state, _) do
    state
  end
end
