
defmodule Util do
    def lineToGame(input) do
        parts = String.split(input, ":")
        [head|tail] = parts

        game = hd(tl(String.split(head, " "))); #extract game ID
        maps = String.split(hd(tail), ";")
          |> Enum.map(fn x -> parseRound(x) end)

        maxValues = mergeColorQuantities(maps)
          #|> Enum.reduce(%{}, &combineMaps/2)
        {String.to_integer(game) , maxValues}

    end

    defp parseRound(input) do
        colors = String.split(input, ",")
          |> Enum.map(&String.trim/1)
          |> Enum.map(fn x -> List.to_tuple(String.split(x, " ", trim: true)) end )
          |> Enum.reduce(%{}, &incrementMap/2)
    end

    defp incrementMap({colorVal, colorName}, map) do
      Map.update(map, colorName, String.to_integer(colorVal), fn x -> x + String.to_integer(colorVal) end)
    end

    defp mergeColorQuantities(color_maps) do
      Enum.reduce(color_maps, %{}, fn(map, acc) ->
        Map.merge(acc, map, fn(_key, acc_val, map_val) ->
          max(acc_val, map_val)
        end)
      end)
    end

    def gamePossible(game) do
      gameNum = elem(game, 0)
      gameVals = elem(game,1)
      cond do
        Map.get(gameVals, "red", 100) <= 12 and Map.get(gameVals, "blue", 100) <= 14 and Map.get(gameVals, "green", 100) <= 13 ->
          gameNum
        true ->
          0
      end
    end

    def minGamePower(game) do
      gameVals = elem(game,1)
      Map.get(gameVals, "red", 1) * Map.get(gameVals, "blue", 1) * Map.get(gameVals, "green", 1)
    end
end

stream = File.stream!("day2_input")

games = stream
  |> Enum.map(&Util.lineToGame/1)
  #|> Enum.map(&Util.gamePossible/1) # Part 1
  |> Enum.map(&Util.minGamePower/1) # Part 2
  |> Enum.sum()

IO.inspect(games)
