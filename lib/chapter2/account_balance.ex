defmodule Chapter2.AccountBalance do
  use GenServer
  require Logger

  def start_link(account_number) do
    GenServer.start_link(__MODULE__, account_number, name: via(account_number))
  end

  @impl true
  def init(account_number) do
    {:ok, %{balance: 0, account_number: account_number}}
  end

  defp via(account_number) do
    {:via, Registry, {Registry.AccountProjectors, account_number}}
  end

  def apply_event(%{account_number: account} = event)
      when is_binary(account) do
    case Registry.lookup(Registry.AccountProjectors, account) do
      [{pid, _}] ->
        apply_event(pid, event)

      _ ->
        Logger.debug("Attempt to apply event to non-existant account, starting projector")
        {:ok, pid} = start_link(account)
        apply_event(pid, event)
    end
  end

  def apply_event(pid, event) when is_pid(pid) do
    GenServer.cast(pid, {:handle_event, event})
  end

  @impl true
  def handle_cast({:handle_event, evt}, state) do
    {:noreply, handle_event(state, evt)}
  end

  def handle_event(%{balance: bal} = s, %{event_type: :amount_withdrawn, value: v}) do
    %{s | balance: bal - v}
  end

  def handle_event(%{balance: bal} = s, %{event_type: :amount_deposited, value: v}) do
    %{s | balance: bal + v}
  end

  def handle_event(%{balance: bal} = s, %{event_type: :fee_applied, value: v}) do
    %{s | balance: bal - v}
  end

  def lookup_balance(account_number) when is_binary(account_number) do
    with [{pid, _}] <-
           Registry.lookup(Registry.AccountProjectors, account_number) do
      {:ok, GenServer.call(pid, :get_balance)}
    else
      _ -> {:error, :unknown_account}
    end
  end

  @impl true
  def handle_call(:get_balance, _from, state) do
    {:reply, state.balance, state}
  end
end
