defmodule FastShoppingList do
  use GenServer

  @moduledoc """
  Documentation for FastShoppingList.
  """

  require Logger

  def start_link(options \\ []) do
      GenServer.start_link(__MODULE__, :ok, options ++ [name: FastShoppingList])
  end

  def init(:ok) do
    FastShoppingList.Database.load()
    {:ok, nil}
  end
end
