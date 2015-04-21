defmodule ExNum.Mixfile do
  use Mix.Project

  def project do
    [app: :complex,
     version: "0.1.0",
     elixir: "~> 1.0",
     deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:erlport, github: "hdima/erlport", compile: "make", only: [:dev, :test]},
      {:random, github: "mururu/elixir-random", only: [:dev, :test]},
      {:exmath, github: "kemonomachi/exmath"}
    ]
  end
end
