defmodule PacPlug.Router do
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

	get "/assets/:name" do
		content = File.read!("assets/#{name}")
		send_resp(conn, 200, content)
	end

  get "/pacmans/stream" do
		conn = put_resp_content_type(conn, "text/event-stream")
		conn = send_chunked(conn, 200)
		event_loop(conn)
  end

	# TODO: restuful routes!
	post "/pacmans/add/:name" do
		Pacman.add binary_to_atom(name)
		conn = put_resp_content_type(conn, "application/json")
		{:ok, json_str} = JSON.encode [name: name]
		send_resp(conn, 201, json_str)
	end

	put "/pacmans/turn/:name/:direction" do
		Pacman.turn binary_to_atom(name), binary_to_atom(direction)
		conn = put_resp_content_type(conn, "application/json")
		{:ok, json_str} = JSON.encode [name: name, direction: direction]
		send_resp(conn, 204, json_str)
	end

  match _ do
    send_resp(conn, 404, "oops")
  end

	def event_loop(conn) do
		Pacman.streaming fn(state)->
												 {:ok, conn} = chunk(conn, "data: #{state}\n\n")
										 end
	end

end
