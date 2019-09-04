defmodule TestGenstage.MixProject do
  use Mix.Project

  def project do
    [
      app: :test_genstage,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {TestGenstage.Application, []}
    ]
  end

  defp deps do
    [
      {:gen_stage, "~> 0.14.2"}
    ]
  end
end
