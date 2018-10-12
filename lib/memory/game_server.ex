defmodule Memory.GameServer do
   use GenServer

   alias Memory.Game
   alias MemoryWeb.Endpoint

   ## Client Interface
   def start_link(_args) do
     GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
   end

   def view(game, user) do
     GenServer.call(__MODULE__, {:view, game, user})
   end

   def click(game, user, id) do
     GenServer.call(__MODULE__, {:click, game, user, id})
   end

   def timecheck(game, user) do
     GenServer.call(__MODULE__, {:timecheck, game, user})
   end

  def getView(game) do
    GenServer.call(__MODULE__, {:getView, game})
  end

  ## Implementations
  def init(state) do
    IO.puts("init")
    {:ok, state}
  end
  def handle_call({:view, game, user}, _from, state) do
    gg = Map.get(state, game, Game.new)
    vv = Game.client_view(gg, user)
    {:reply, vv, Map.put(state, game, gg)}
  end
  def handle_call({:click, game, user, id}, _from, state) do
    gg = Map.get(state, game, Game.new)
      |> Game.click(user, id)
    Process.send_after(self(), :timecheck, 1_000)
    {:reply, Game.client_view(gg, user), Map.put(state, game, gg)}
  end

  def handle_call({:getView, game}, _from, state) do
    gg = Map.get(state, game, Game.new)
    vv = Game.client_view(gg, "potato")
    {:reply, Game.client_view(gg, "mango"), gg}
  end

  def handle_info(:timecheck, state) do
    IO.puts("timecheck")
    IO.inspect(state)
      state =
        Enum.reduce(state, %{}, fn {k, game}, acc ->
        IO.puts("game:" <> to_string(k))
        gg = game 
           |> Game.handle_time(to_string(k))
        IO.puts("should be updating")
        MemoryWeb.Endpoint.broadcast(k, "update_board_set_view", gg)
        Map.put(acc, k, gg)
      end)
    {:noreply, state}
  end
end
