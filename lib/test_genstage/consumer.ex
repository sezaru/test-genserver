defmodule Consumer do
  use GenStage

  require Logger

  def start_link(args) do
    GenStage.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    {:consumer, :no_state, subscribe_to: [{Ema, max_demand: 1}]}
  end

  def handle_events(events, _from, state) do
    Logger.warn("Consumer events: #{inspect events, charlists: :as_lists}")

    # Process.sleep(5_000)

    {:noreply, [], state}
  end
end
