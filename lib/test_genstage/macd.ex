defmodule Macd do
  use GenStage

  require Logger

  def start_link(args) do
    GenStage.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    {:producer_consumer, %{by_tag: %{}, by_name: %{}},
     subscribe_to: [{Sma, max_demand: 1, name: :sma}, {Ema, max_demand: 1, name: :ema}],
     dispatcher: GenStage.BroadcastDispatcher}
  end

  def handle_subscribe(:consumer, _opts, _to_or_from, state) do
    {:automatic, state}
  end

  def handle_subscribe(:producer, opts, {_pid, tag}, state) do
    name = Keyword.fetch!(opts, :name)

    state = state |> put_in([:by_tag, tag], name) |> put_in([:by_name, name], [])

    {:automatic, state}
  end

  def handle_events(events, {_pid, tag}, state) do
    Logger.error("#{inspect(tag)}")
    Logger.warn("MACD events: #{inspect(events, charlists: :as_lists)}")

    Logger.error("before #{inspect(state, charlists: :as_lists)}")
    
    name = get_in(state, [:by_tag, tag])

    {events, state} =
      state
      |> update_in([:by_name, name], &(&1 ++ events))
      |> compute()

    Logger.error("after #{inspect(state, charlists: :as_lists)}")

    {:noreply, events, state}
  end

  defp compute(%{by_name: %{sma: sma_values, ema: ema_values}} = state) do
    Logger.error("middle #{inspect(state, charlists: :as_lists)}")
    
    {sma_values, ema_values, results} = do_compute(sma_values, ema_values, [])

    state = state
    |> put_in([:by_name, :sma], sma_values)
    |> put_in([:by_name, :ema], ema_values)

    {results, state}
  end

  defp do_compute([], ema_values, results), do: {[], ema_values, results}
  defp do_compute(sma_values, [], results), do: {sma_values, [], results}

  defp do_compute([sma | sma_rest], [ema | ema_rest], results),
    do: do_compute(sma_rest, ema_rest, results ++ [real_compute(sma, ema)])

  defp real_compute(sma, ema), do: sma + ema
end
