defmodule Chapter3.MessageBroadcaster do
  use GenState
  require Logger

  def start_link(_) do
    GenState.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Injects a raw message that is not in cloud event format
  """
  def broadcast_message(message) do
    GenStage.call(__MODULE__, {:notify, message})
  end

  @doc """
  Injects a cloud event to be published to the stage pipeline
  """
  def broadcast_event(event) do
    GenStage.call(__MODULE__, {:notify_event, event})
  end

  @impl true
  def init(:ok) do
    {:producer, :ok, dispatcher: GenStage.BroadcastDispatcher}
  end

  @impl true
  def handle_call({:notify, message}, _from, state) do
    {:reply, :ok, [to_event(message)], state}
  end

  @impl true
  def handle_call({:notify_event, event}, _from, state) do
    {:reply, :ok, [event], state}
  end

  @impl true
  def handle_demand(_demand, state) do
    {:noreply, [], state}
  end

  defp to_event(%{
         type: :aircraft_identified,
         message: %{icao_address: _icao, callsign: _callsign, emitter_category: _cat} = msg
       }) do
    new_cloudevent("aircraft_identified", msg)
  end

  defp to_event(%{
         type: :squawk_received,
         message: %{squawk: _squawk, icao_address: _icao} = msg
       }) do
    new_cloudevent("squawk_received", msg)
  end

  defp to_event(%{
         type: :position_reported,
         message: %{
           icao_address: icao,
           position: %{altitude: alt, longitude: long, latitude: lat}
         }
       }) do
    new_cloudevent("position_reported", %{
      icao_address: icao,
      altitude: alt,
      longitude: long,
      latitude: lat
    })
  end

  defp to_event(%{
         type: :velocity_reported,
         message:
           %{
             heading: _heading,
             ground_speed: _ground_speed,
             vertical_rate: _vertical_rate,
             vertical_rate_source: vertical_rate_source
           } = msg
       }) do
    source =
      case vertical_rate_source do
        :barometric_pressure -> "barometric"
        :geometric -> "geometric"
        _ -> "unknown"
      end

    new_cloudevent("velocity_reported", %{msg | vertical_rate_source: source})
  end

  defp to_event(msg) do
    Logger.log("Unknown message: #{inspect(msg)}")
    %{}
  end

  defp new_cloudevent(type, data) do
    %{
      "specversion" => "1.0",
      "type" => "org.book.flighttracker.#{String.downcase(type)}",
      "source" => "radio_aggregator",
      "id" => UUID.uuid4(),
      "datacontenttype" => "application/json",
      "time" => DateTime.utc_now() |> DateTime.to_iso8601(),
      "data" => data
    }
    |> Cloudevents.from_map!()
    |> Cloudevents.to_json()
  end
end
