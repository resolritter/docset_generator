defmodule DocsetGenerator.MixProject do
  use Mix.Project

  def project do
    [
      app: :docset_generator,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: [main_module: DocsetGenerator]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dir_walker, github: "pragdave/dir_walker"},
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev], runtime: false}
    ]
  end
end
