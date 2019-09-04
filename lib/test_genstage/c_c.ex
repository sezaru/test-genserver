defmodule CC do
  use GenStage

  require Logger

  def start_link(args) do
    GenStage.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    {:consumer, :no_state, subscribe_to: [{PcC, max_demand: 1}]}
  end

  def handle_events(events, _from, state) do
    Logger.warn("CC events: #{inspect events, charlists: :as_lists}")

    {:noreply, [], state}
  end
end
