defmodule TradeTypes.Trade do
  alias TradeTypes.Trade

  @type t :: %Trade{
          timestamp: integer,
          amount: float,
          price: float
        }

  defstruct(
    timestamp: 0,
    amount: 0.0,
    price: 0.0
  )

  def new(timestamp, amount, price) do
    %Trade{timestamp: timestamp, amount: amount, price: price}
  end
end
