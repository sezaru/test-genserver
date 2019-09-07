defmodule TestGenstage.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    producer = [{Producer, []}]
    transformers = [{Transformers.Close, []}, {Transformers.Delta, []}]
    acc_indicators = [{Indicators.Rsi.Rsi14, []}]
    # multi_input_indicators = [{Macd.Macd2612, []}]
    strategies = [{SampleStrategy, []}]
    
    children = producer ++ transformers ++ acc_indicators ++ strategies

    opts = [strategy: :rest_for_one, name: TestGenstage.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
