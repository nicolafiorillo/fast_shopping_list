defmodule FastShoppingList.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/search_start" do
    send_resp(conn, 200, "start")
  end

  get "/search_contains" do
    send_resp(conn, 200, "contains")
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end
