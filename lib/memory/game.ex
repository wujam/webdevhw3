# TODO

defmodule Memory.Game do
  def new do 
    %{
      cells: gen_cells(),
      lastclicked: "?",
      cell_vals: ["?", "?", "?", "?", "?", "?", "?", "?","?", "?", "?", "?","?", "?", "?", "?"],
      cell_ids: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
      players: []
      }
  end

  def new(players) do
    Map.put(new(), :players, players)
  end
  def default_player() do
    %{
      clicks: 0
    }
  end

  def client_view(game, user) do
    ps = Enum.map game.players, fn {pn, pi} ->
      %{ name: pn, score: pi.score}
    end
    Map.put(game, :players, ps)
  end
  def gen_cells do
    ["A", "A", "B", "B", "C", "C", "D", "D", "E", "E", "F", "F", "G", "G", "H", "H"]
    |> Enum.take_random(16)
  end

  def click(game, player, tilenum) do
    
    IO.puts("game cells is #{game.cells}")
    IO.puts("clicked cell is #{Enum.at(game.cells, tilenum)}")
    game
    |> Map.put(:cell_vals, update_list(game.cell_vals, Enum.at(game.cells, tilenum), tilenum))
  end

  def update_list(list, element, 0) do
    [element | tl(list)]
  end

  def update_list(list, element, position) do
    [hd(list) | update_list(tl(list), element, position - 1)] 
  end
end
