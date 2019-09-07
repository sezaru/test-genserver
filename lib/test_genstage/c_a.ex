defmodule CA do
  use GenStage

  require Logger

  @sold 1.0
  @bought 3.0

  def start_link(args) do
    GenStage.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    {:consumer, %{status: :normal}, subscribe_to: [{Sma.Sma3, max_demand: 1}]}
  end

  def handle_events(events, _from, state) do
    state = compute(events, state)

    {:noreply, [], state}
  end

  defp compute([event | rest], state) do
    state = do_compute(event, state)
    
    compute(rest, state)
  end

  defp compute([], state) do
    state
  end

  defp do_compute(event, %{status: :normal} = state) when event > @bought,
    do: trigger_overbought(state)

  defp do_compute(event, %{status: :normal} = state) when event < @sold,
    do: trigger_oversold(state)

  defp do_compute(_event, %{status: :normal} = state), do: state

  defp do_compute(event, %{status: :overbought} = state) when event < @sold,
    do: trigger_oversold(state)

  defp do_compute(event, %{status: :overbought} = state) when event <= @bought,
    do: trigger_normal(state)

  defp do_compute(event, %{status: :overbought} = state), do: state

  defp do_compute(event, %{status: :oversold} = state) when event > @bought,
    do: trigger_overbought(state)

  defp do_compute(event, %{status: :oversold} = state) when event >= @sold,
    do: trigger_normal(state)

  defp do_compute(event, %{status: :oversold} = state), do: state

  defp trigger_overbought(state) do
    Logger.warn("OVERBOUGHT")

    %{state | status: :overbought}
  end

  defp trigger_oversold(state) do
    Logger.warn("OVERSOULD")

    %{state | status: :oversold}
  end

  defp trigger_normal(state) do
    Logger.warn("BACK TO NORMAL")

    %{state | status: :normal}
  end
end
