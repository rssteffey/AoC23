
defmodule Util do
  def checkSymbol({x, y}, grid) do
      #ensure char at x,y is not in [".", "1", "2", etc]
      nonSymbols = [".","1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
      cond do
        #if out of bounds
        x >= tuple_size(grid) || y >= tuple_size(elem(grid,0)) -> false
        x <= 0 || y <=0 -> false
        #else
        true -> !Enum.member?(nonSymbols, elem(elem(grid, x), y))
      end
  end

  def checkSurroundingsForSymbols({startX, startY}, numLength, grid) do
    #length increases along y
     coords = startX-1..startX+1
      |> Enum.map(fn x ->
        startY-numLength-1..startY
          |> Enum.map(fn y ->
            {x, y}
          end)
      end)
      |> List.flatten()

      Enum.any?(coords, fn coord -> checkSymbol(coord, grid) end)
      #IO.puts(coords)

  end

  def checkDigit(char) do
    digits = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
    Enum.member?(digits, char)
  end

  def normalRecurse([], _, bigAcc, _grid) do
    # final value?
    bigAcc
  end
  def normalRecurse([currentChar | remainingChars], {xc, yc}, bigAcc, grid) do
    # If head is digit, recurse to digit handling
    cond do
      # Number goes to sum acc
      checkDigit(currentChar) -> digitRecurse(remainingChars, currentChar, {xc, yc + 1}, bigAcc, grid)
      # Otherwise carry on
      true -> normalRecurse(remainingChars, {xc, yc + 1}, bigAcc, grid)
    end
  end

  def digitRecurse([], acc, _coord, bigAcc, _grid) do
    bigAcc + Integer.parse(acc)
  end
  def digitRecurse([currentChar | remainingChars], acc, {xc, yc}, bigAcc, grid) do
    cond do
      # Number continues
      checkDigit(currentChar) -> digitRecurse(remainingChars, acc <> currentChar, {xc, yc+1}, bigAcc, grid)
      # Number has touching symbol, add the total and continue parsing
      Util.checkSurroundingsForSymbols({xc, yc-1}, String.length(acc), grid) ->
        normalRecurse(remainingChars, {xc, yc+1}, bigAcc + elem(Integer.parse(acc), 0), grid)
      # Number discarded, continue parsing
      true ->
        normalRecurse(remainingChars, {xc, yc+1}, bigAcc, grid)
    end
  end
end

file = File.read!("day3_input")

#tuple form for sequential memory index lookups
grid = file
  |> String.split("\n", trim: true)
  |> Enum.map(fn x -> List.to_tuple(String.split(x, "", [trim: true])) end)
  |> List.to_tuple()

#list form for iterating
rows = file
|> String.split("\n", trim: true)
output = Enum.with_index(rows)
|> Enum.map(fn {row, index} -> Util.normalRecurse(String.split(row, ""), {index, 0}, 0, grid) end)
|> Enum.sum()

# Util.checkSurroundingsForSymbols({5, 7}, 3)

# function to find numbers and applicable grid spaces?

#iterate
#  if digit and prior was . , add to list

#IO.puts(Util.checkSymbol(grid, {4, 8}))

IO.puts(output)

#File.write("day3_output", output |> Enum.join("\n"))
