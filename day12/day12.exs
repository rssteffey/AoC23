defmodule Util do

  def solveLine(line) do
    IO.puts("Solve line: " <> line)

    [grid|sequences] = String.split(String.trim(line), " ", trim: true)

    seq = hd(sequences)
      |> String.split(",", trim: true)
      |> Enum.map(fn x -> String.to_integer(x) end)

    springRecord = String.split(grid, "", trim: true)

    poss = generatePossibilities(seq, Enum.count(springRecord))

    # Then pattern match those possibilities against a record regex
    recordString = List.to_string(springRecord) |> String.replace(".", "\\.") |> String.replace("?", ".")
    {_status, regex} = Regex.compile(recordString)

    poss
      |> Enum.filter(fn poss -> Regex.match?(regex, List.to_string(poss)) end)
      |> Enum.count()
  end

  def generatePossibilities(sequences, gridLength) do
    extraSpace = gridLength - (Enum.sum(sequences) + Enum.count(sequences) - 1) #Sum is springs to fill, count is mandatory gap between
    combinations = placeGroup(sequences, extraSpace, [])
    #Because I am bad at Elixir and my recursed combinations are now nested at various levels, we have a hacky fix (Flatten it, and redistribute on the known length)
    List.flatten(combinations)
      |> Enum.chunk_every(gridLength)
  end

  #Recurse through each group,
  defp placeGroup([group|[]], remSpace, acc) do
    Enum.to_list(0..remSpace)
      |> Enum.map(fn leadSpace ->
        leadingSpaces = List.duplicate(".", leadSpace)
        groupChars = List.duplicate("#", group)
        # Last group means we need to add empty space to end
        finalEmpty = List.duplicate(".", (remSpace - leadSpace))
        acc ++ leadingSpaces ++ groupChars ++ finalEmpty
      end)
  end
  defp placeGroup([group|remainingSequences], remSpace, acc) do
    #current group plus space for each remaining group
    Enum.to_list(0..remSpace)
      |> Enum.map(fn leadSpace ->
        leadingSpaces = List.duplicate(".", leadSpace)
        groupChars = List.duplicate("#", group)
        placeGroup(remainingSequences, remSpace - leadSpace, acc ++ leadingSpaces ++ groupChars ++ ["."])
      end)
  end

end

defmodule Part2 do
  def expandLine(line) do
    [grid|sequences] = String.split(String.trim(line), " ", trim: true)

    newRecord = List.duplicate(grid, 5)
      |> Enum.join("?")
    newSeq = List.duplicate(hd(sequences), 5)
      |> Enum.join(",")

    newRecord <> " " <> newSeq
  end
end


output = File.stream!("testInput")
  |> Enum.map(fn x -> Part2.expandLine(x) end) #Part 2 (naive)
  |> Enum.map(fn x -> Util.solveLine(x) end)
  |> Enum.sum()

IO.inspect(output)
