# TODO

defmodule Memory.Game do
  def new do 
    %{
      cells: gen_cells(),
      clicks: 0,
      lastclicked: "?",
      cell_vals: ["?", "?", "?", "?", "?", "?", "?", "?","?", "?", "?", "?","?", "?", "?", "?"],
      cell_ids: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
      }
  end
  def client_view(game, user) do
    game
  end
  def gen_cells do
    ["A", "A", "B", "B", "C", "C", "D", "D", "E", "E", "F", "F", "G", "G", "H", "H"]
    |> Enum.take_random(16)
  end

  def click(game, tilenum, cell_vals, cells) do
    tilenumatom = tilenum
    |> Integer.to_string()
    |> String.to_atom()
    game = Map.put(game, :cell_vals, update_list(cell_vals, cells[tilenumatom], tilenum))
    game
  end

  def update_list(list, element, 0) do
    [element | tl(list)]
  end
  def update_list(list, element, position) do
    [hd(list) | update_list(tl(list), element, position - 1)] 
  end
end
