defmodule DanielkingdevPlug.MixProject do
  use Mix.Project

  def project do
    [
      app: :danielkingdev_plug,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {DanielkingdevPlug.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:bandit, ">= 0.6.8"},
      {:atomex, "0.3.0"},
      {:earmark, "~> 1.4"},
      {:stemmer, "~> 1.1"},
      {:req, "~> 0.3.0"}
    ]
  end
end
