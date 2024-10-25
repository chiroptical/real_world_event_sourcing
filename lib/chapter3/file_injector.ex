defmodule Chapter3.FileInjector do
  alias Chapter3.MessageBroadcaster
  use GenServer
  require Logger

  def start_link(file) do
    GenServer.start_link(__MODULE__, file, name: __MODULE__)
  end

  @impl true
  def init(file) do
    Process.send_after(self(), :read_file, 2_000)

    {:ok, file}
  end

  @impl true
  def handle_info(:read_file, file) do
    File.stream!(file)
    |> Enum.map(&String.trim/1)
    |> Enum.each(fn event -> MessageBroadcaster.broadcast_event(event) end)

    {:noreply, file}
  end
end
