defmodule Transformers.Close do
  use TransformerIndicator,
    subscribe_to: Producer

  def do_compute(candle, state) do
    {candle.close, state}
  end
end
