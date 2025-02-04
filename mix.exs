defmodule ExSanity.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_sanity,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:httpoison, ">= 1.8.0"},
      {:jason, ">= 1.1.0"},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false},
      {:phoenix_html, ">= 2.14.2"},
      {:phoenix_html_helpers, "~> 1.0"}
    ]
  end
end
