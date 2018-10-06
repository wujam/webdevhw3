defmodule MemoryWeb.GamesChannel do
  use MemoryWeb, :channel

  alias Memory.Game
  alias Memory.BackupAgent

  def join("games:" <> name, payload, socket) do
    if authorized?(payload) do
      game = BackupAgent.get(name) || Game.new()
      game = Game.client_view(game)
      socket = socket
      |> assign(:game, game)
      |> assign(:name, name)
      BackupAgent.put(name, game)
      
      IO.puts("printing out game on join")
      Enum.each game, fn {k, v} ->
        IO.puts "#{k} --> #{v}"
      end 
      {:ok, %{"join" => name, "game" => Game.client_view(game)}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("click", %{"id" => id, "cell_vals" => cell_vals, "cells" => cells}, socket) do
    name = socket.assigns[:name]
    game = Game.click(socket.assigns[:game], id, cell_vals, cells)
    socket = assign(socket, :game, game)
    BackupAgent.put(name, game)
    {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
  end

  def handle_in("save", %{"state" => state}, socket) do
    socket = assign(socket, :game, state)
    BackupAgent.put(socket.assigns[:name], socket.assigns[:game])
    {:reply, {:ok, %{}}, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
