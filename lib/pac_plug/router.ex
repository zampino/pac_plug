defmodule PacPlug.Router do
  use Plug.Router
  # import Plug.Conn

  plug :match
  plug :dispatch

  def init(_options\\[]) do
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
    IO.puts ">>>> #{id} for #{inspect(self)} <<<<"
    Pacman.register_output self
    stream_state(id, conn)
  end

  post "/pacmans/add/:id/:name" do
    Pacman.add :"pacman_#{id}" #, name: name
    conn = put_resp_content_type(conn, "application/json")
    {:ok, json_str} = JSON.encode [id: id, name: name]
    send_resp(conn, 201, json_str)
  end

  put "/pacmans/turn/:id/:name/:direction" do
    Pacman.turn :"pacman_#{id}", String.to_atom(direction)
    conn = put_resp_content_type(conn, "application/json")
    {:ok, json_str} = JSON.encode [id: id, name: name, direction: direction]
    send_resp(conn, 204, json_str)
  end

  match _ do
    send_resp(conn, 404, "oops")
  end

  def stream_state(id, conn) do
    receive do
      {:state, state} ->
        send_state(id, conn, state)
        stream_state(id, conn)
    end
  end

  def send_state(id, conn, state) do
    {status, conn_or_reason} = chunk(conn, "data: #{state}\n\n")
    if status == :error do
      IO.puts("#{status}: #{conn_or_reason}, exiting...")
      Pacman.remove_output self
      Pacman.remove :"pacman_#{id}"
      :timer.sleep 1000
      Process.exit self, :normal
    end
  end

end
