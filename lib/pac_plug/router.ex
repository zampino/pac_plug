defmodule PacPlug.Router do
  use Plug.Router
  import Plug.Connection

  plug :match
  plug :dispatch

	def init(options\\[]) do
	end

	def boot do
		event_loop_pid = spawn_link __MODULE__, :event_loop, [HashDict.new]
		# conntections_collector_pid = spawn_link __MODULE__, :collect_connections, []
		Process.register event_loop_pid, :event_loop
		Pacman.register_output :event_loop
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
		# send :event_loop, {:conn, {id, conn}}
		{:ok, conn} = chunk(conn, "data: connected\n\n")
		# conn
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

	# def event_loop(conns) do
	# 	IO.puts inspect(conns)
	# 	receive do
	# 		{:conn, {id, conn}} ->
	# 			conns = Dict.put conns, id, conn
	# 			event_loop(conns)
	# 	end
	# 	Pacman.streaming fn(state)->
	# 											 conns |> Enum.each fn(conn)-> sendState(conn, state) end
  #                        receive do
	# 												 {:conn, conn} ->
	# 													 conns = List.flatten conns, conn
	# 											 after 0 ->
	# 												 nil
	# 											 end
	# 									 end
	# end

	def event_loop(conns) do
		receive do
			{:state, state} ->
				IO.puts "state arrived: #{state}"
				Enum.each conns, fn({id, conn}) -> send_state(conn, state) end
			  event_loop conns
			{:conn, {id, conn}} ->
				IO.puts "new conn: #{id}"
				conns = Dict.put_new(conns, id, conn)
				event_loop conns
		after
			0 -> event_loop(conns)
		end
	end

	def send_state(conn, state) do
		# IO.puts inspect(conn)
		{status, conn_or_reason} = chunk(conn, "data: #{state}\n\n")
		if status == :error, do: IO.puts(conn_or_reason)
	end

end
