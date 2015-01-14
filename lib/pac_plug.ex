# require PacPlug.Router

defmodule PacPlug do
  use Application

  def init(_options\\[]) do
  end

  def start(_how, _) do
    IO.puts "booting"
    Pacman.boot
    port = String.to_integer System.get_env["PORT"] || "4000"
    Plug.Adapters.Cowboy.http PacPlug, [], port: port
  end

  def call(conn, _opts) do
    PacPlug.Router.call(conn, PacPlug.Router.init)
  end

end
