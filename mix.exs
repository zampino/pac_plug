defmodule Lab.Mixfile do
  use Mix.Project

  def project do
    [ app: :lab,
      version: "0.0.1",
      elixir: "~> 0.12.4",
      deps: deps ]
  end

  # Configuration for the OTP application
  # def application do
  #   [mod: { Lab, [] }]
  # end

  defp deps do
    [{ :cowboy, github: "extend/cowboy" },
		 { :pacman, path: "../pacman"},
     { :plug, "0.3.0", github: "elixir-lang/plug" }]
  end
end
