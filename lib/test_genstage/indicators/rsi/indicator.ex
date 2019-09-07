defmodule Indicators.Rsi.Indicator do
  defmacro __using__(opts) do
    accumulate_until = Keyword.fetch!(opts, :accumulate_until)

    quote do
      use AccIndicator,
        subscribe_to: Transformers.Delta,
        accumulate_until: unquote(accumulate_until)

      def do_compute(deltas, state) do
        size = length(deltas)

        gains = Enum.filter(deltas, &is_greater_than_zero?/1) |> Enum.sum() |> Kernel./(size)

        losses =
          Enum.filter(deltas, &is_lesser_than_zero?/1)
          |> Enum.map(&abs/1)
          |> Enum.sum()
          |> Kernel./(size)

        rsi = 100.0 - 100.0 / (1.0 + gains / losses)

        {rsi, state}
      end

      defp is_greater_than_zero?(value), do: value > 0
      defp is_lesser_than_zero?(value), do: value < 0
    end
  end
end
