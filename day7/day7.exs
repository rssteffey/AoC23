defmodule Util do
  def createHandTuple(handString) do
    [cardsString|rest] = String.split(handString, " ", trim: true)
    bid = String.to_integer(hd(rest))
    cards = String.split(cardsString, "", trim: true)
    {cards, bid}
  end

  def orderHands(handList) do
    # I have it on good authority that Elixir sorting is stable, so if we sort in reversing priority, it should retain lower importances

    handList
      |> Enum.sort_by(fn x -> elem(elem(x, 1), 4) end) # Here we're going up through each card in the hand
      |> Enum.sort_by(fn x -> elem(elem(x, 1), 3) end) # The secondaryRank struct
      |> Enum.sort_by(fn x -> elem(elem(x, 1), 2) end) # Unnamed tuples, apologies
      |> Enum.sort_by(fn x -> elem(elem(x, 1), 1) end) # Could I have changed to a named map in the time it took to write these comments?
      |> Enum.sort_by(fn x -> elem(elem(x, 1), 0) end) # ¯\_(ツ)_/¯
      |> Enum.sort_by(fn x -> elem(x, 0) end) # Actual hand rank
  end

  def getProfits(sortedHands) do
    sortedHands
    |> Enum.with_index()
    |> Enum.map(fn {x, i} -> (i+1) * elem(x, 3) end)
  end
end

defmodule Part1 do

  def getHandSortingStruct({cards, bid}) do
    primaryRank = getHandRank(cards)
    secondaryRank = getCardsValue(cards)

    {primaryRank, secondaryRank, cards, bid}
  end

  def getHandRank(hand) do
    # Determine hand type, and return higher values for better hands
    gb = Enum.group_by(hand, &(&1))
    counts = Enum.map(gb, fn {_,val} -> length(val) end)  |> Enum.sort() |> Enum.reverse()
    maxCards = counts |> Enum.max

    cond do
      maxCards == 5 ->
        7
      maxCards == 4 ->
        6
      counts == [3, 2] ->
        5
      maxCards == 3 ->
        4
      counts == [2, 2, 1] ->
        2
      maxCards == 2 ->
        1
      true ->
        0

    end
  end

  defp getCardsValue(hand) do
    cardVals = %{"A" => 14, "K" => 13, "Q"=> 12, "J"=> 11, "T"=> 10, "9"=> 9, "8"=> 8, "7"=> 7, "6"=> 6, "5"=> 5, "4"=> 4, "3"=> 3, "2"=> 2}
    handVals = Enum.map(hand, fn x -> Map.get(cardVals, x) end)

    List.to_tuple(handVals)
  end
end

defmodule Part2 do

  def getHandSortingStruct({cards, bid}) do
    primaryRank = getHandRank(cards)
    secondaryRank = getCardsValue(cards)

    {primaryRank, secondaryRank, cards, bid}
  end

  defp getHandRank(hand) do
    # J can always help by pretending to be the next highest count, so take them out for now
    jokerless = hand |> Enum.filter(fn x-> x != "J" end)
    IO.inspect(jokerless)

    cond do
      Enum.count(jokerless) == 0 -> 7 # I briefly gave this 9001.  That was a bug. (5 jokers still ties 5 anything else)
      true ->

        gb = Enum.group_by(jokerless, &(&1))
        jokerlessCount = Enum.map(gb, fn {item,val} -> {length(val), item} end)  |> Enum.sort() |> Enum.reverse()
        mostCommonVal = elem(hd(jokerlessCount), 1)


        newHand = Enum.map(hand, fn x -> cond do
          x == "J" ->
            mostCommonVal
          true ->
            x
          end
        end)

        Part1.getHandRank(newHand)
      end
  end

  defp getCardsValue(hand) do
    cardVals = %{"A" => 14, "K" => 13, "Q"=> 12, "T"=> 10, "9"=> 9, "8"=> 8, "7"=> 7, "6"=> 6, "5"=> 5, "4"=> 4, "3"=> 3, "2"=> 2, "J"=> 1}
    handVals = Enum.map(hand, fn x -> Map.get(cardVals, x) end)

    List.to_tuple(handVals)
  end
end


file = File.read!("input")

hands = file
|> String.split("\n", trim: true)
|> Enum.map(&Util.createHandTuple/1)

_part1Structs = hands |> Enum.map(&Part1.getHandSortingStruct/1)
part2Structs = hands |> Enum.map(&Part2.getHandSortingStruct/1)

sorted = Util.orderHands(part2Structs)
result = Util.getProfits(sorted) |> Enum.sum()

IO.inspect(result)
