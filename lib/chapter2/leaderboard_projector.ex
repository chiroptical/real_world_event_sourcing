defmodule Chapter2.LeaderboardProjector do
  use GenServer
  require Logger

  def start_link() do
    GenServer.start_link(__MODULE__, nil)
  end

  def apply_event(pid, evt) do
    GenServer.cast(pid, {:handle_event, evt})
  end

  def get_top10(pid) do
    GenServer.cast(pid, :get_top10)
  end

  @impl true
  def init(_) do
    {:ok, %{scores: %{}, top10: []}}
  end

  @impl true
  def handle_call({:get_score, attacker}, _from, state) do
    {:reply, Map.get(state.scores, attacker, 0), state}
  end

  @impl true
  def handle_call(:get_top10, _from, state) do
    {:reply, state.top10, state}
  end

  @impl true
  def handle_cast({:handle_event, %{event_type: :zombie_killed, attacker: atk}}, state) do
    new_scores = Map.update(state.scores, atk, 1, &(&1 + 1))
    {:noreply, %{state | scores: new_scores, top10: rerank(new_scores)}}
  end

  # Probably more efficient to take the attacker and insert it into the top10
  # but this is just an example.
  defp rerank(scores) when is_map(scores) do
    scores
    |> Map.to_list()
    |> Enum.sort(fn {_key1, val1}, {_key2, val2} -> val1 >= val2 end)
    |> Enum.take(10)
  end

  # Note, if we needed to switch this to top 10 in the week the modeling can
  # get quite complicated here. However, if you instead fix the time window you
  # could simply insert a '{:week_completed}' event.
end
