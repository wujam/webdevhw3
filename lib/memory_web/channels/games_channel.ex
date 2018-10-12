defmodule MemoryWeb.GamesChannel do
  use MemoryWeb, :channel

  alias Memory.GameServer

  def join("games:" <> game, payload, socket) do
    if authorized?(payload) do
      socket = assign(socket, :game, game)
      view = GameServer.view(game, socket.assigns[:user])
      {:ok, %{"join" => game, "game" => view}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("click", %{"id" => id}, socket) do
    view = GameServer.click(socket.assigns[:game], socket.assigns[:user], id)
    broadcast_from! socket, "update_board", view
    {:reply, {:ok, %{ "game" => view}}, socket}
  end
  

  def handle_in("blast", %{}, socket) do
    view = GameServer.getView(socket.assigns[:game])
    IO.puts("blast")
    
    IO.inspect(view)
    broadcast_from! socket, "update_board", view
    {:reply, {:ok, %{"game" => view}}, socket}
  end
  
  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
