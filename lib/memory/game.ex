# TODO

defmodule Memory.Game do
  alias MemoryWeb.Endpoint
  def new do 
    %{
      cells: gen_cells(),
      lastclicked_id: -1,
      cell_ids: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
      cell_vals: ["?", "?", "?", "?", "?", "?", "?", "?", "?", "?", "?", "?","?", "?", "?", "?"],
      players: [],
      lastclicks: [],
      solutions: [],
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

  def client_view(game, _user) do
    #ps = Enum.map game.players, fn {pn, pi} ->
    #  %{ name: pn, score: pi.score}
    #end
    #Map.put(game, :players, ps)

    
    cell_vals =
      if length(game.lastclicks) >= 1 do
        ["?", "?", "?", "?", "?", "?", "?", "?", "?", "?", "?", "?","?", "?", "?", "?"]
        |> put_lastclicks_in_cell_vals(game)
      else
        ["?", "?", "?", "?", "?", "?", "?", "?", "?", "?", "?", "?","?", "?", "?", "?"]
      end
    cell_vals = 
      if game.lastclicked_id >= 0 do
        update_list(cell_vals, Enum.at(game.cells, game.lastclicked_id), game.lastclicked_id)
      else
        cell_vals
      end
    cell_vals = Enum.reduce(game.solutions, cell_vals, fn [id1, id2], acc ->
        acc
        |> update_list(Enum.at(game.cells, id1), id1)
        |> update_list(Enum.at(game.cells, id2), id2)
      end)
    game
    |> Map.put(:cell_vals, cell_vals)
  end

  def put_lastclicks_in_cell_vals(cell_vals, game) do
    cell_vals
    |> update_list(Enum.at(game.cells, Enum.at(Enum.at(game.lastclicks, 0), 0)), Enum.at(Enum.at(game.lastclicks, 0), 0))
    |> update_list(Enum.at(game.cells, Enum.at(Enum.at(game.lastclicks, 0), 1)), Enum.at(Enum.at(game.lastclicks, 0), 1))
  end

  def gen_cells do
    ["A", "A", "B", "B", "C", "C", "D", "D", "E", "E", "F", "F", "G", "G", "H", "H"]
    |> Enum.take_random(16)
  end

  def handle_time(game, gamename) do
    cell_vals = Enum.reduce(game.lastclicks, game.cell_vals, fn [id1, id2, time], acc ->
        IO.puts("checking #{id1} and #{id2} timedelta is #{time - :os.system_time(:milli_seconds)}")
        if time <= :os.system_time(:milli_seconds) do
          IO.puts("clearing #{id1} and #{id2}")
          acc
          |> update_list("?", id1)
          |> update_list("?", id2)
        else
          acc
        end
      end)
    last_clicks = Enum.reduce(game.lastclicks, [], fn [id1, id2, time], acc ->
        if time <= :os.system_time(:milli_seconds) do
          acc
        else
          [[id1, id2, time] | acc]
        end
      end)

    game
    |> Map.put(:cell_vals, cell_vals)
    |> Map.put(:lastclicks, last_clicks)
  end

  def click(game, player, tilenum) do
    clicked_value = Enum.at(game.cells, tilenum)
    
    game =
      if length(game.lastclicks) >= 1 do
        game
      else
        game = game
          |> Map.put(:cell_vals, update_list(game.cell_vals, clicked_value, tilenum))
        if game.lastclicked_id == -1 do
          game
          |> Map.put(:lastclicked_id, tilenum)
        else
          game
          |> Map.put(:lastclicks, [[tilenum, game.lastclicked_id, :os.system_time(:milli_seconds) + 1_000]
                                   | game.lastclicks])
          |> Map.put(:lastclicked_id, -1)
          |> record_solved()
        end
      end
    IO.puts("clicked #{tilenum} lastclicked #{game.lastclicked_id}")
    IO.inspect(game)
    game
  end

  def record_solved(game) do
    last_clicks = Enum.at(game.lastclicks, 0)

    if Enum.at(game.cells, Enum.at(last_clicks, 0)) == Enum.at(game.cells, Enum.at(last_clicks, 1)) do
      IO.puts("checking #{Enum.at(last_clicks, 0)} and #{Enum.at(last_clicks, 1)}")
      game
      |> Map.put(:solutions, [[Enum.at(last_clicks, 0), Enum.at(last_clicks, 1)] | game.solutions])
      |> Map.put(:lastclicks, [])
    else
      game
    end
  end

  def update_list(list, element, 0) do
    [element | tl(list)]
  end

  def update_list(list, element, position) do
    [hd(list) | update_list(tl(list), element, position - 1)] 
  end
end
