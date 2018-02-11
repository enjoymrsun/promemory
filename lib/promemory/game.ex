defmodule Promemory.Game do
  def new do
    %{
      tiles: next_board(),
      score: 0,
      reversed_tiles: [],
      click_times: 0
    }
  end

  def client_view(game) do
    %{
      skel: skeleton(game.tiles),
      score: game.score,
      click: game.click_times,
      reversed: Enum.count(game.reversed_tiles)
    }
  end

  def handle_click(game, pos) do
    %{tiles: newTiles, score: newScore, reversed_tiles: newRT, click_times: newCT} = game
    len = Enum.count(newRT)
    if len <= 1 do
      {:ok, t} = Enum.fetch(newTiles, pos)
      t = %Promemory.Tile{t | reversed: true}
      newTiles = List.replace_at(newTiles, pos, t)
      newScore = newScore - 8
      newRT = List.insert_at(newRT, 0, t)
    end
    newCT = newCT + 1

    %{
      tiles: newTiles,
      score: newScore,
      reversed_tiles: newRT,
      click_times: newCT
    }
  end

  def compare_tiles(game) do
    %{tiles: newTiles, score: newScore, reversed_tiles: newRT, click_times: newCT} = game
    if Enum.count(newRT) == 2 do
      rtOne = List.first(newRT)
      rtTwo = List.last(newRT)
      if rtOne.value == rtTwo.value && rtOne.pos != rtTwo.pos do
        newRTOne = %Promemory.Tile{rtOne | killed: true}
        newRTTwo = %Promemory.Tile{rtTwo | killed: true}
        newTiles = List.replace_at(newTiles, rtOne.pos, newRTOne)
        newTiles = List.replace_at(newTiles, rtTwo.pos, newRTTwo)
        newScore = newScore + 80
      else
        newRTOne = %Promemory.Tile{rtOne | reversed: false}
        newRTTwo = %Promemory.Tile{rtTwo | reversed: false}
        newTiles = List.replace_at(newTiles, rtOne.pos, newRTOne)
        newTiles = List.replace_at(newTiles, rtTwo.pos, newRTTwo)
      end
      newRT = []
    end

    %{
      tiles: newTiles,
      score: newScore,
      reversed_tiles: newRT,
      click_times: newCT
    }
  end

  defp skeleton(tiles) do
    Enum.map tiles, fn t ->
      eval_tile(t)
    end
  end

  defp eval_tile(tile) do
    cond do
      tile.killed -> "OK"
      tile.reversed -> tile.value
      true -> "?"
    end
  end

  defp next_letters_pos do
    letter_list = ["A","B","C","D","E","F","G","H","A","B","C","D","E","F","G","H"]
    Enum.shuffle(letter_list)
  end

  defp next_board do
    next_letters_pos()
    |> Enum.with_index
    |> Enum.map(fn({l, i}) ->
      %Promemory.Tile{value: l, pos: i} end)
  end










end
