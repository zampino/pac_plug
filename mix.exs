defmodule PacPlug.Mixfile do
  use Mix.Project

  def project do
    [ app: :pac_plug,
      version: "0.1.0",
      elixir: "~> 0.12.5",
			github: "zampino/pac_plug",
      deps: deps ]
  end

  # Configuration for the OTP application
  # def application do
  #   [mod: { Lab, [] }]
  # end

  defp deps do
    [{ :cowboy, github: "extend/cowboy" },
		 { :pacman, github: "zampino/pacman", branch: "master"},
     { :plug, "0.3.0", github: "elixir-lang/plug" }]
  end
end
