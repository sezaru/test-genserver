defmodule Producer do
  use GenStage

  require Logger

  def start_link(args) do
    GenStage.start_link(__MODULE__, args, name: Producer)
  end

  def init(_args) do
    {:producer, 1, dispatcher: GenStage.BroadcastDispatcher}
  end

  def sync_notify(candle, timeout \\ 5_000) do
    GenStage.call(__MODULE__, {:notify, candle}, timeout)
  end

  def handle_call({:notify, event}, _from, state) do
    {:reply, :ok, [event], state}
  end

  def handle_demand(demand, state) when demand > 0 do
    {:noreply, [], state}
  end
end
