
defmodule Util do
    def lineToGame(input) do
        parts = String.split(input, ":")
        [head|tail] = parts

        game = hd(tl(String.split(head, " "))); #extract game ID
        gameToTuple(game, hd(tail))
    end

    def gameToTuple(gameNum, input) do
        rounds = String.split(input, ";")
          |> Enum.map(fn x -> parseRound(x) end)
        {gameNum , rounds}
    end

    def parseRound(input) do
        colors = String.split(input, ",")
          |> Enum.map(fn x -> List.to_tuple(String.split(x, " ", trim: true)) end )
          |> Enum.reduce(%{}, &incrementMap/2)

          IO.puts(colors)
    end

    defp incrementMap(color, map) do
      Map.update(map, color[0], 0, &(&1 + color[1]))
  end
end

stream = File.stream!("day2_input")

games = stream
  |> Enum.map(&Util.lineToGame/1)

File.write("day2_output", games |> Enum.join("\n"))
