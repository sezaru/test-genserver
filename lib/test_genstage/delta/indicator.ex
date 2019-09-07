defmodule Transformers.Delta do
  use TransformerIndicator,
    subscribe_to: Transformers.Close,
    state: %{last_close: nil}

  def do_compute(close, %{last_close: nil}) do
    {nil, %{last_close: close}}
  end

  def do_compute(close, %{last_close: last_close}) do
    
    {close - last_close, %{last_close: close}}
  end
end
