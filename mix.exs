defmodule SBV2SRT.MixProject do
  use Mix.Project

  def project do
    [
      app: :sbv2srt,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: releases(),
      escript: [main_module: SBV2SRT.CLI]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ] ++ maybe_mod()
  end

  defp maybe_mod do
    # Only start the application module in production (for Burrito)
    # In development, we want to use the escript or call CLI directly
    if Mix.env() == :prod do
      [mod: {SBV2SRT.Application, []}]
    else
      []
    end
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:burrito, github: "burrito-elixir/burrito"}
    ]
  end

  # Run "mix help releases" to learn about releases.
  def releases do
    [
      sbv2srt: [
        steps: [:assemble, &Burrito.wrap/1],
        burrito: [
          targets: [
            macos: [os: :darwin, cpu: :x86_64],
            linux: [os: :linux, cpu: :x86_64],
            windows: [os: :windows, cpu: :x86_64]
          ]
        ]
      ]
    ]
  end
end
