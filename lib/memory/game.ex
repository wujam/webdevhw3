# TODO

defmodule Memory.Game do
  def new do 
    %{
      cells: gen_cells(),
      lastclicked_id: -1,
      cell_vals: ["?", "?", "?", "?", "?", "?", "?", "?","?", "?", "?", "?","?", "?", "?", "?"],
      cell_ids: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
      players: [],
      lastclicks: [],
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
    #ps = Enum.map game.players, fn {pn, pi} ->
    #  %{ name: pn, score: pi.score}
    #end
    #Map.put(game, :players, ps)
    game
  end
  def gen_cells do
    ["A", "A", "B", "B", "C", "C", "D", "D", "E", "E", "F", "F", "G", "G", "H", "H"]
    |> Enum.take_random(16)
  end

  def click(game, player, tilenum) do
    clicked_value = Enum.at(game.cells, tilenum)
    IO.puts("game cells is #{game.cells}")
    IO.puts("clicked value is #{tilenum}")
    game = game
    |> Map.put(:cell_vals, update_list(game.cell_vals, clicked_value, tilenum))
    
    game =
      if game.lastclicked_id == -1 do
        game
        |> Map.put(:lastclicked_id, tilenum)
      else
        game
        |> Map.put(:lastclicks, [[tilenum, game.lastclicked_id, :os.system_time(:milli_seconds) + 1_000]
                                 | game.lastclicks])
        |> Map.put(:lastclicked_id, -1)
        |> (fn game ->
          cell_vals = Enum.reduce(game.lastclicks, game.cell_vals, fn [id1, id2, time], acc ->
            if time - :os.system_time(:milli_seconds) <= 0 do
              acc
              |> update_list("?", id1)
              |> update_list("?", id2)
            else
              acc
            end
          end)
          last_clicks = Enum.reduce(game.lastclicks, game.lastclicks, fn [id1, id2, time], acc ->
            if time - :os.system_time(:milli_seconds) <= 0 do
              acc
              # TODO broadcast message somewhere, maybe set a flag here to notify
            else
              [[id1, id2, time] | acc]
            end
          end)
          game
          |> Map.put(:cell_vals, cell_vals)
          |> Map.put(:lastclicks, last_clicks)
        end).()
      end
  end

  def update_list(list, element, 0) do
    [element | tl(list)]
  end

  def update_list(list, element, position) do
    [hd(list) | update_list(tl(list), element, position - 1)] 
  end
end
