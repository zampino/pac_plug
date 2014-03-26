require PacPlug.Router

defmodule PacPlug do
  import Plug.Connection

	def init(options\\[]) do
		# IO.puts "booting"
	end

	def boot do
		Pacman.boot
		Plug.Adapters.Cowboy.http PacPlug, []
	end

	def call(conn, _opts) do
		conn = Plug.Parsers.call(conn, parsers: [:urlencoded, :multipart])
		PacPlug.Router.call(conn, [])
	end

end
