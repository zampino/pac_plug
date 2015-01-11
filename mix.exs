defmodule PacPlug.Mixfile do
  use Mix.Project

  def project do
    [ app: :pac_plug,
      version: "0.1.0",
      elixir: "~> 1.0.2",
      github: "zampino/pac_plug",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [
      applications: [:cowboy, :plug],
      mod: {PacPlug, []}
    ]
  end

  defp deps do
    [{ :cowboy, "~> 1.0.0" },
     # { :pacman, path: "../pacman" },
     { :pacman, github: "zampino/pacman", branch: "master"},
     { :plug, "~> 0.9" }]
  end
end
