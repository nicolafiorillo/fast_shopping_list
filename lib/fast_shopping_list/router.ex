defmodule FastShoppingList.Router do
  import Plug.Conn
  use Plug.Router
  require Logger

  plug :match
  plug :dispatch

  get "/search_start" do
    send_response(conn, &search_start/1)
  end

  get "/search_contains" do
    send_response(conn, &search_contains/1)
  end

  match _ do
    send_resp(conn, 404, "oops")
  end

  defp send_response(conn, func) do
    conn = fetch_query_params(conn)
    res = func.(conn.query_params)

    Logger.info("Found #{length(res)} elements.")
    conn
    |> put_resp_header("Content-Type", "application/json")
    |> send_resp(200, Poison.encode!(res))
  end

  defp search_start(%{"s" => string}) do
    Logger.info "Searching starting from: #{string}"
    FastShoppingList.Database.search_start(string) |> Enum.map(fn {name, _foods} -> name end)
  end
  defp search_start(_), do: []

  defp search_contains(%{"s" => string}) do
    Logger.info "Searching containing: #{string}"
    FastShoppingList.Database.search_contains(string) |> Enum.map(fn {name, _foods} -> name end)
  end
  defp search_contains(_), do: []
end
