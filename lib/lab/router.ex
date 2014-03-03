defmodule Lab.Router do
  use Plug.Router
  import Plug.Connection

  plug :match
  plug :dispatch

	def init(options\\[]) do
	end

	get "/" do
		conn = put_resp_content_type(conn, "text/html")
		text = File.read!("views/home.html")
    send_resp(conn, 200, text)
	end

  get "/stream" do
		conn = put_resp_content_type(conn, "text/event-stream")
		conn = send_chunked(conn, 200)
		event_loop(conn)
  end

  match _ do
    send_resp(conn, 404, "oops")
  end

	def event_loop(conn) do
		Pacman.streaming fn(state)->
												 {:ok, conn} = chunk(conn, "data: #{state}\n\n")
										 end
		# receive do
		# 	{:grid_state, state} ->
		# 		{ :ok, conn } = chunk(conn, "data: #{state}\n\n")
		# 		:timer.sleep 500
		# 		event_loop(conn, state)
		# after
		# 	0 ->
		# 		{ :ok, conn } = chunk(conn, "data: #{state}\n\n")
		# 		:timer.sleep 500
		# 		event_loop(conn, state)
		# end
	end

end
