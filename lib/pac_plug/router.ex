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

  get "/pacmans/stream/:id" do
		conn = put_resp_content_type(conn, "text/event-stream")
		conn = send_chunked(conn, 200)
		{:ok, conn} = chunk(conn, "retry: 10000\nevent: handshake\ndata: #{id}\n\n")
		conn_id = binary_to_atom(id)
		IO.puts ">>>> #{conn_id} for #{inspect(self)} <<<<"
		Process.register self, conn_id
		Pacman.register_output conn_id

		# NOTE: this call MUST be blocking
		#       otherwise with either eventsource tries
		#       a reconnect or :dispatch complains we
		#       didn't return a connection
		stream_state(conn)
  end

	# TODO: restuful routes with the parser plug!
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

	def stream_state(conn) do
		receive do
			{:state, state} ->
				send_state(conn, state)
				stream_state(conn)
		end
	end

	def send_state(conn, state) do
		{status, conn_or_reason} = chunk(conn, "data: #{state}\n\n")
		if status == :error, do: IO.puts("#{status}: #{conn_or_reason}")
	end

end
