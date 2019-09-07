defmodule Ema.Indicator do
  defmacro __using__(opts) do
    accumulate_until = Keyword.fetch!(opts, :accumulate_until)
    
    quote do
      use AccIndicator,
        subscribe_to: Transformers.Close,
        accumulate_until: unquote(accumulate_until)

      require Logger
      def do_compute(closes, state) do
        size = length(closes)

        response = closes |> Enum.sum() |> Kernel./(size)

        Logger.warn("#{__MODULE__}: #{inspect response}")

        {closes |> Enum.sum() |> Kernel./(size), state}
      end
    end
  end
end
