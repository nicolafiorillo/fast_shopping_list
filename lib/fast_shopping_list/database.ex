defmodule FastShoppingList.Database do
  use GenServer

  @moduledoc """
  Documentation for FastShoppingList.
  """

  require Logger

  def start_link(options \\ []) do
      GenServer.start_link(__MODULE__, :ok, options ++ [name: FastShoppingList.Database])
  end

  def init(:ok) do
    {:ok, []}
  end

  def load() do
    GenServer.cast(FastShoppingList.Database, :load)
  end

  def search_start(string) when is_bitstring(string) do
    GenServer.call(FastShoppingList.Database, {:search_start, string})
  end

  def search_contains(string) when is_bitstring(string) do
    GenServer.call(FastShoppingList.Database, {:search_contains, string})
  end

  def handle_cast(:load, _state) do
    {:noreply, load_data()}
  end

  def handle_call({:search_start, string}, _from, database) do
    res = Enum.filter(database, fn {name, foods} ->
      String.starts_with?(name, string)
    end)
    {:reply, res, database}
  end

  def handle_call({:search_contains, string}, _from, database) do
    res = Enum.filter(database, fn {name, foods} ->
      String.contains?(name, string)
    end)
    {:reply, res, database}
  end

  defp load_data() do
    file_name = Application.get_env(:fast_shopping_list, :foods_db)
    Logger.info("Reading database: #{file_name}")

    Sqlitex.with_db(file_name, fn(db) ->
      {:ok, foods} = Sqlitex.query(db, "SELECT * FROM food;")

      Logger.info("Preparing data...")
      foods =
        foods
        |> Enum.reduce(%{}, fn food, all_foods ->
          food_map = Enum.into(food, %{})
          cibo = food_map.nome_cibo
          food_map = Map.delete(food_map, :nome_cibo)

          case all_foods[cibo] do
            nil       -> Map.put(all_foods, cibo, [food_map])
            food_list -> Map.put(all_foods, cibo, food_list ++ [food_map])
          end
        end)

      Logger.info("Data ready: #{length(Map.keys(foods))} foods.")

      foods
    end)
  end
end
