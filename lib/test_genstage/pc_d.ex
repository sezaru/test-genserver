defmodule PcD do
  use GenStage

  require Logger

  def start_link(args) do
    GenStage.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    {:producer_consumer, %{by_tag: %{}, by_name: %{}},
     subscribe_to: [{PcB, max_demand: 1, name: :pcb}, {PcC, max_demand: 1, name: :pcc}],
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
    Logger.warn("PcD events: #{inspect(events, charlists: :as_lists)}")

    name = get_in(state, [:by_tag, tag])

    {events, state} =
      state
      |> update_in([:by_name, name], &(&1 ++ events))
      |> compute()

    {:noreply, events, state}
  end

  defp compute(%{by_name: %{pcb: b_values, pcc: c_values}} = state) do
    {b_values, c_values, results} = do_compute(b_values, c_values, [])

    state = state
    |> put_in([:by_name, :pcb], b_values)
    |> put_in([:by_name, :pcc], c_values)

    {results, state}
  end

  defp do_compute([], c_values, results), do: {[], c_values, results}
  defp do_compute(b_values, [], results), do: {b_values, [], results}

  defp do_compute([b | b_rest], [c | c_rest], results),
    do: do_compute(b_rest, c_rest, results ++ [real_compute(b, c)])

  defp real_compute(b, c), do: b + c
end
