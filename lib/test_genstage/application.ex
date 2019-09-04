defmodule TestGenstage.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Producer, []},
      {PcA, []},
      {PcB, []},
      {PcC, []},
      {PcD, []},
      {CA, []},
      {CB, []},
      {CC, []},
      {CD, []}
    ]

    opts = [strategy: :rest_for_one, name: TestGenstage.Supervisor]
    
    Supervisor.start_link(children, opts)
  end
end
