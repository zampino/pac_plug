require Lab.Router

defmodule Lab do
  import Plug.Connection

	def init(options\\[]) do
		# IO.puts "booting"
	end

	def boot do
		Pacman.boot
		# pid = spawn_link(Plug.Adapters.Cowboy, :http, [Lab, []])
		Plug.Adapters.Cowboy.http Lab, []
	end

	def call(conn, _opts) do
		Lab.Router.call(conn, Lab.Router.init([]))
	end

end
