defmodule Util do
  def tupleToValues({winString, numString}) do
      winners = String.split(winString, " ", [trim: true])
      numbers = String.split(numString, " ", [trim: true])

      filteredWinners = winners
        |> Enum.filter(fn x -> Enum.member?(numbers, x) end)

      numWins = length(filteredWinners)

      cond do
        numWins == 0 -> 0
        true ->
          filteredWinners
            |> Enum.map(fn _x -> 1 end)
            |> Enum.sum()
      end

  end

  def createGame(gameString) do
    [gameNum|rest] = String.split(gameString, ":")
    [winString|loseList] = String.split(hd(rest), "|", [trim: true])
    loseString = hd(loseList)
    winCount = tupleToValues({winString, loseString})

    %{game: gameNum, wins: winCount, cards: 1}
  end

  def listToUpdateCardCounts(gameArray) do
    updateCardCountsRecursively([], gameArray)
  end

  def updateCardCountsRecursively(acc, []) do
    acc
  end
  def updateCardCountsRecursively(acc, oldArray) do
    [curr|rest] = oldArray
    #IO.inspect(curr)
    newArray = acc ++ [curr]
    newRest = updateCounts([], Map.get(curr, :cards), Map.get(curr, :wins), rest)
    updateCardCountsRecursively(newArray, newRest)
  end

  def updateCounts(acc, _, 0, rest) do
    acc ++ rest
  end
  def updateCounts(acc, numCards, roundsToClone, gameArray) do
    [curr|rest] = gameArray
    #IO.inspect(curr)
    newEntry = Map.update(curr, :cards, 1, fn x -> x + numCards end)
    updateCounts(acc ++ [newEntry], numCards, roundsToClone - 1, rest)
  end

end


file = File.read!("day4_input")

# Part 1
# pairs = file
#   |> String.split("\n", trim: true)
#   |> Enum.map(fn x -> hd(tl(String.split(x, ":"))) end)
#   |> Enum.map(fn x -> List.to_tuple(String.split(x, "|", [trim: true])) end)
#   |> Enum.map(fn x -> Util.tupleToValues(x) end)
#   |> Enum.sum()

#   IO.inspect(pairs)

#Part 2
results = file
  |> String.split("\n", trim: true)
  |> Enum.map(fn x -> Util.createGame(x) end)
  |> Util.listToUpdateCardCounts()
  |> Enum.map(fn x -> x.cards end)
  |> Enum.sum()

IO.inspect(results)
