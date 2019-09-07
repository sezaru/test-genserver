defmodule Macd.Indicator do
  defmacro __using__(opts) do
    subscribe_to = Keyword.fetch!(opts, :subscribe_to)
    
    quote do
      use MultiInputIndicator,
        inputs: [:slow_ema, :fast_ema],
        subscribe_to: unquote(subscribe_to)

      require Logger
      
      def do_compute(slow_ema, fast_ema, state) do
        response = fast_ema - slow_ema

        Logger.warn("#{__MODULE__}: #{inspect response}")

        {fast_ema - slow_ema, state}
      end
    end
  end
end
