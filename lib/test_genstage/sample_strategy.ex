defmodule SampleStrategy do
  use Strategy,
    subscribe_to: Indicators.Rsi.Rsi14,
    state: %{status: :normal}

  require Logger

  # def do_compute(event, state) do
  #   Logger.warn event
  # end

  @oversold 30.0
  @overbought 70.0

  def do_compute(event, %{status: :normal} = state) when event > @overbought,
    do: trigger_overbought(state)

  def do_compute(event, %{status: :normal} = state) when event < @oversold,
    do: trigger_oversold(state)

  def do_compute(_event, %{status: :normal} = state), do: state

  def do_compute(event, %{status: :overbought} = state) when event < @oversold,
    do: trigger_oversold(state)

  def do_compute(event, %{status: :overbought} = state) when event <= @overbought,
    do: trigger_normal(state)

  def do_compute(_event, %{status: :overbought} = state), do: state

  def do_compute(event, %{status: :oversold} = state) when event > @overbought,
    do: trigger_overbought(state)

  def do_compute(event, %{status: :oversold} = state) when event >= @oversold,
    do: trigger_normal(state)

  def do_compute(_event, %{status: :oversold} = state), do: state

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
