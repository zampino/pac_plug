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
    Plug.Adapters.Cowboy.http PacPlug, []
  end

  def call(conn, _opts) do
    # conn = Plug.Parsers.call(conn, parsers: [:urlencoded, :multipart])
    PacPlug.Router.call(conn, PacPlug.Router.init)
  end

end
