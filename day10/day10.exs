defmodule Util do

  def createRow({inputLine, rowIndex}) do
    String.split(inputLine, "", trim: true)
    |> Enum.with_index()
    |> Enum.map(fn {x, colIndex} -> {x, rowIndex, colIndex} end)
  end

  def createEmptyGrid(rows, cols) do
    Enum.to_list(0..rows)
    |> Enum.map(
        fn _x -> Enum.to_list(0..cols)
          |> Enum.map(fn _y -> "." end)
        end)
  end

  def findStart(rows) do
    row = Enum.find(rows, fn x -> Enum.any?(x, fn {y, _, _} -> y == "S" end) end)
    Enum.find(row, fn {x, _, _} -> x == "S" end)
  end

  def findStartConnector({_, row, col}, grid) do
    findStartConnector({"S", row, col}, grid, "")
  end
  def findStartConnector({_, row, col}, grid, skipChar) do
    maxRow = tuple_size(grid)
    maxCol = tuple_size(elem(grid, 0))

    # Check surrounding 4 for any valid pipes, and return first found
    cond do
      #Above
      skipChar != "A" and row > 0 and Enum.member?(["|", "F", "7"], elem(elem(elem(grid, row - 1), col), 0)) ->
        {elem(elem(elem(grid, row - 1), col), 0), row - 1, col}
      #Below
      skipChar != "B" and row < maxRow and Enum.member?(["|", "L", "J"], elem(elem(elem(grid, row + 1), col), 0)) ->
        {elem(elem(elem(grid, row + 1), col), 0), row + 1, col}
      #Left
      skipChar != "L" and col > 0 and Enum.member?(["-", "F", "L"], elem(elem(elem(grid, row), col - 1), 0)) ->
        {elem(elem(elem(grid, row), col - 1), 0), row, col - 1}
      #Right
      skipChar != "R" and col < maxCol and Enum.member?(["-", "J", "7"], elem(elem(elem(grid, row), col + 1), 0)) ->
        {elem(elem(elem(grid, row), col + 1), 0), row, col + 1}
    end
  end
end

defmodule Part1 do
  # Start/End
  def followPipe({"S", row, col}, _, grid, stepCount) do
    cond do
      stepCount == 0 ->
        connector = Util.findStartConnector({"S", row, col}, grid)
        followPipe(connector, {row, col}, grid, stepCount+1)
      true ->
        stepCount / 2
      end
  end
  # Horizontal
  def followPipe({"-", currRow, currCol}, {_, oldCol}, grid, stepCount) do
    newCol = currCol + (currCol - oldCol)
    newChar = elem(elem(grid, currRow), newCol)
    followPipe(newChar, {currRow, currCol}, grid, stepCount + 1)
  end
  # Vertical
  def followPipe({"|", currRow, currCol}, {oldRow, _}, grid, stepCount) do
    newRow = currRow + (currRow - oldRow)
    newChar = elem(elem(grid, newRow), currCol)
    followPipe(newChar, {currRow, currCol}, grid, stepCount + 1)
  end
  # F corner
  def followPipe({"F", currRow, currCol}, {oldRow, oldCol}, grid, stepCount) do
    newCol = currCol + (oldRow - currRow)
    newRow = currRow + (oldCol - currCol)
    newChar = elem(elem(grid, newRow), newCol)
    followPipe(newChar, {currRow, currCol}, grid, stepCount + 1)
  end
  # 7 corner
  def followPipe({"7", currRow, currCol}, {oldRow, oldCol}, grid, stepCount) do
    newCol = currCol + (currRow - oldRow)
    newRow = currRow + (currCol - oldCol)
    newChar = elem(elem(grid, newRow), newCol)
    followPipe(newChar, {currRow, currCol}, grid, stepCount + 1)
  end
  # L corner
  def followPipe({"L", currRow, currCol}, {oldRow, oldCol}, grid, stepCount) do
    newCol = currCol + (currRow - oldRow)
    newRow = currRow + (currCol - oldCol)
    newChar = elem(elem(grid, newRow), newCol)
    followPipe(newChar, {currRow, currCol}, grid, stepCount + 1)
  end
  # J corner
  def followPipe({"J", currRow, currCol}, {oldRow, oldCol}, grid, stepCount) do
    newCol = currCol + (oldRow - currRow)
    newRow = currRow + (oldCol - currCol)
    newChar = elem(elem(grid, newRow), newCol)
    followPipe(newChar, {currRow, currCol}, grid, stepCount + 1)
  end
end

defmodule Part2 do

  # Replace S with the appropriate character
  def determineStartPipe({startChar, startRow, startCol}, cleanGrid, tupleGrid) do
    connectA = Util.findStartConnector({startChar, startRow, startCol}, tupleGrid)
    diffA = {startRow - elem(connectA, 1), startCol - elem(connectA, 2)}
    dirChar = case diffA do
      {1, 0} -> "A"
      {-1, 0} -> "B"
      {0, 1} -> "L"
      {0, -1} -> "R"
    end

    start = {startChar, startRow, startCol}
    connectB = Util.findStartConnector(start, tupleGrid, dirChar)
    diffB = {startRow - elem(connectB, 1), startCol - elem(connectB, 2)}

    # Playing with fire, but since I check A, B, L, R in that order, I should only need one check for each combo instead of accounting for both orders of {diffA, diffB}
    replaceChar = case {diffA, diffB} do
      {{1, 0}, {-1, 0}} ->  "|"
      {{1, 0}, {0, -1}} ->  "L"
      {{1, 0}, {0, 1}} ->  "J"
      {{-1, 0}, {0, -1}} ->  "F"
      {{-1, 0}, {0, 1}} ->  "7"
      {{0, 1}, {0, -1}} ->  "-"
    end

    newRow = List.replace_at(Enum.at(cleanGrid, elem(start, 1)), elem(start, 2), replaceChar)
    List.replace_at(cleanGrid, elem(start, 1), newRow)
  end

  def calcSpaceWithinRow([head|rest], mainAcc, subAcc, pairOpen) do
    # Pairs of | | count interior spaces between them
    # sequential corner pairs can be irrelevant, or act as a "|"; see countCornerPair() for better explanation
    cond do
      rest == [] -> mainAcc
      # Corner Case (subroutine)
      head == "F" or head == "L" ->
        {equivalentPipe, remainingRow} = countCornerPair(head, rest)
        cond do
          equivalentPipe and pairOpen -> calcSpaceWithinRow(remainingRow, mainAcc + subAcc, 0, false)
          equivalentPipe and !pairOpen -> calcSpaceWithinRow(remainingRow, mainAcc, subAcc, true)
          true -> calcSpaceWithinRow(remainingRow, mainAcc, subAcc, pairOpen)
        end
      # Standard pipes
      pairOpen and head == "|" -> calcSpaceWithinRow(rest, mainAcc + subAcc, 0, false)
      !pairOpen and head == "|" -> calcSpaceWithinRow(rest, mainAcc, subAcc, true)
      # Counting interior space
      pairOpen -> calcSpaceWithinRow(rest, mainAcc, subAcc + 1, true)
      # Nothing important
      true -> calcSpaceWithinRow(rest, mainAcc, subAcc, false)
    end
  end

  # The gist of this is that pairs with the same vertical direction don't meaningfully change the topology on this row (F-7 and L-J)
  # While opposite direction pairs act as if they're another "|" (F-J and L-7)
  def countCornerPair(start, [head|rest]) do
    cond do
      start == "F" and head == "J" -> {true, rest}
      start == "L" and head == "7" -> {true, rest}
      start == "F" and head == "7" -> {false, rest}
      start == "L" and head == "J" -> {false, rest}
      true -> countCornerPair(start, rest)
    end
  end

  # I hate to repeat these, but for the sake of keeping my Part 1 history preserved, here they are again but with the new clean grid filling
  def drawPipe({"S", row, col}, _, grid, 0, cleanGrid) do
    connector = Util.findStartConnector({"S", row, col}, grid)
    drawPipe(connector, {row, col}, grid, 1, cleanGrid)
  end
  def drawPipe({"S", row, col}, _, grid, _stepCount, cleanGrid) do
    # End by replacing start pipe and returning the grid
    determineStartPipe({"S", row, col}, cleanGrid, grid)
  end
  # Horizontal
  def drawPipe({"-", currRow, currCol}, {_, oldCol}, grid, stepCount, cleanGrid) do
    newCol = currCol + (currCol - oldCol)
    newChar = elem(elem(grid, currRow), newCol)
    # Generate clean grid
    newRow = List.replace_at(Enum.at(cleanGrid, currRow), currCol, "-")
    newGrid = List.replace_at(cleanGrid, currRow, newRow)
    drawPipe(newChar, {currRow, currCol}, grid, stepCount + 1, newGrid)
  end
  # Vertical
  def drawPipe({"|", currRow, currCol}, {oldRow, _}, grid, stepCount, cleanGrid) do
    newRow = currRow + (currRow - oldRow)
    newChar = elem(elem(grid, newRow), currCol)
    newRow = List.replace_at(Enum.at(cleanGrid, currRow), currCol, "|")
    newGrid = List.replace_at(cleanGrid, currRow, newRow)
    drawPipe(newChar, {currRow, currCol}, grid, stepCount + 1, newGrid)
  end
  # F corner
  def drawPipe({"F", currRow, currCol}, {oldRow, oldCol}, grid, stepCount, cleanGrid) do
    newCol = currCol + (oldRow - currRow)
    newRow = currRow + (oldCol - currCol)
    newChar = elem(elem(grid, newRow), newCol)
    newRow = List.replace_at(Enum.at(cleanGrid, currRow), currCol, "F")
    newGrid = List.replace_at(cleanGrid, currRow, newRow)
    drawPipe(newChar, {currRow, currCol}, grid, stepCount + 1, newGrid)
  end
  # 7 corner
  def drawPipe({"7", currRow, currCol}, {oldRow, oldCol}, grid, stepCount, cleanGrid) do
    newCol = currCol + (currRow - oldRow)
    newRow = currRow + (currCol - oldCol)
    newChar = elem(elem(grid, newRow), newCol)
    newRow = List.replace_at(Enum.at(cleanGrid, currRow), currCol, "7")
    newGrid = List.replace_at(cleanGrid, currRow, newRow)
    drawPipe(newChar, {currRow, currCol}, grid, stepCount + 1, newGrid)
  end
  # L corner
  def drawPipe({"L", currRow, currCol}, {oldRow, oldCol}, grid, stepCount, cleanGrid) do
    newCol = currCol + (currRow - oldRow)
    newRow = currRow + (currCol - oldCol)
    newChar = elem(elem(grid, newRow), newCol)
    newRow = List.replace_at(Enum.at(cleanGrid, currRow), currCol, "L")
    newGrid = List.replace_at(cleanGrid, currRow, newRow)
    drawPipe(newChar, {currRow, currCol}, grid, stepCount + 1, newGrid)
  end
  # J corner
  def drawPipe({"J", currRow, currCol}, {oldRow, oldCol}, grid, stepCount, cleanGrid) do
    newCol = currCol + (oldRow - currRow)
    newRow = currRow + (oldCol - currCol)
    newChar = elem(elem(grid, newRow), newCol)
    newRow = List.replace_at(Enum.at(cleanGrid, currRow), currCol, "J")
    newGrid = List.replace_at(cleanGrid, currRow, newRow)
    drawPipe(newChar, {currRow, currCol}, grid, stepCount + 1, newGrid)
  end

end

# Input

rows = File.read!("input")
|> String.split("\n", trim: true)
|> Enum.with_index()
|> Enum.map(&Util.createRow/1)

gridRows = rows
|> Enum.map(fn x -> List.to_tuple(x) end)

start = Util.findStart(rows)
grid = List.to_tuple(gridRows)


# Part 1
#output = Part1.followPipe(start, {nil, nil}, grid, 0)


# Part 2

#I'm too smooth-brained to look at a grid with extraneous pipes, so for my sanity let's work with only the important bits
cleanGrid = Util.createEmptyGrid(tuple_size(grid), tuple_size(elem(grid, 0)))

onlyPipe = Part2.drawPipe(start, {nil, nil}, grid, 0, cleanGrid)

output = onlyPipe
  |> Enum.map(fn x -> Part2.calcSpaceWithinRow(x, 0, 0, false) end)
  |> Enum.sum()

IO.inspect(output)
