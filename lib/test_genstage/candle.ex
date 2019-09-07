defmodule TradeTypes.Candle do
  alias TradeTypes.{Candle, Trade}

  @one_minute 60_000

  @type t :: %Candle{
          timestamp: integer,
          open: float,
          close: float,
          high: float,
          low: float,
          volume: float
        }

  defstruct(
    timestamp: 0,
    open: 0.0,
    close: 0.0,
    high: 0.0,
    low: 0.0,
    volume: 0.0
  )

  def new(_candle = [timestamp, open, close, high, low, volume]) do
    %Candle{
      timestamp: timestamp,
      open: open,
      close: close,
      high: high,
      low: low,
      volume: volume
    }
  end

  def new(
        _candle = %{
          timestamp: timestamp,
          open: open,
          close: close,
          high: high,
          low: low,
          volume: volume
        }
      ) do
    Candle.new([timestamp, open, close, high, low, volume])
  end

  def new(trade = %Trade{}) do
    %Candle{
      timestamp: trade.timestamp - rem(trade.timestamp, @one_minute),
      open: trade.price,
      close: trade.price,
      high: trade.price,
      low: trade.price,
      volume: abs(trade.amount)
    }
  end

  def update(candle = %Candle{}, other_candle = %Candle{}) do
    %Candle{
      candle
      | close: other_candle.close,
        high: max(candle.high, other_candle.high),
        low: min(candle.low, other_candle.low),
        volume: candle.volume + other_candle.volume
    }
  end

  def update(candle = %Candle{}, trade = %Trade{}) do
    %Candle{
      candle
      | close: trade.price,
        high: max(candle.high, trade.price),
        low: min(candle.low, trade.price),
        volume: candle.volume + abs(trade.amount)
    }
  end
end
