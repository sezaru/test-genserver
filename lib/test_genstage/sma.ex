defmodule Sma do
  use GenStage

  require Logger

  def start_link(args) do
    GenStage.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    {:producer_consumer, :no_state,
     subscribe_to: [{Producer, max_demand: 1, bla: :ble}],
     dispatcher: GenStage.BroadcastDispatcher}
  end

  def handle_events(events, _from, state) do
    Logger.warn("SMA events: #{inspect(events, charlists: :as_lists)}")

    events = Enum.map(events, &(&1 + 2))

    {:noreply, events, state}
  end
end
