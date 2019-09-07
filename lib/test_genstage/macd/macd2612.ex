defmodule Macd.Macd2612 do
  use Macd.Indicator,
    subscribe_to: [Ema.Ema26, Ema.Ema12]
end
