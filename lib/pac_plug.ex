# require PacPlug.Router

defmodule PacPlug do
  use Application
  # import Plug.Conn

  def init(_options\\[]) do
    # IO.puts "booting"
  end

  def start(_how, _) do
    IO.puts "booting"
    Pacman.boot
    port = String.to_integer System.get_env["PORT"] || '4000'
    Plug.Adapters.Cowboy.http PacPlug, [], port: port
  end

  def call(conn, _opts) do
    # conn = Plug.Parsers.call(conn, parsers: [:urlencoded, :multipart])
    PacPlug.Router.call(conn, PacPlug.Router.init)
  end

end
