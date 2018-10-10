defmodule Memory.GameServer do
   use GenServer

   alias Memory.Game

   ## Client Interface
   def start_link(_args) do
     GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
   end

   def view(game, user) do
     GenServer.call(__MODULE__, {:view, game, user})
   end

   def click(game, user, id, cell_vals, cells) do
     GenServer.call(__MODULE__, {:click, game, user, id, cell_vals, cells})
   end

  ## Implementations
   def init(state) do
     IO.puts("init")
     {:ok, state}
   end
   def handle_call({:view, game, user}, _from, state) do
     IO.puts(user)
     gg = Map.get(state, game, Game.new)
     vv = Game.client_view(gg, user)
     {:reply, vv, Map.put(state, game, gg)}
   end
  ## TODO
   def handle_call({:click, game, user, id}, _from, state) do
     IO.puts(user)
     gg = Map.get(state, game, Game.new)
     |> Game.click(user, id)
     {:reply, Game.client_view(gg, user), Map.put(state, game, gg)}
   end
 end
