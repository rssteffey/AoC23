
defmodule Util do
  def checkNumber({x, y}, grid) do
      #ensure char at x,y is not in [".", "1", "2", etc]
      digits = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
      cond do
        #if out of bounds
        x >= tuple_size(grid) || y >= tuple_size(elem(grid,0)) -> false
        x <= 0 || y <=0 -> false
        #else
        true -> !Enum.member?(digits, elem(elem(grid, x), y))
      end
  end

  def checkDigit(char) do
    digits = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
    Enum.member?(digits, char)
  end

  def checkStar(char) do
    char == "*"
  end

  def normalRecurse([], _, bigAcc, _grid) do
    bigAcc
  end
  def normalRecurse([currentChar | remainingChars], {xc, yc}, bigAcc, grid) do
    # If head is digit, recurse to digit handling
    cond do
      # Number goes to sum acc
      checkStar(currentChar) ->
        val = returnGearValue({xc, yc}, grid)
        normalRecurse(remainingChars, {xc, yc + 1}, bigAcc + val, grid)
      # Otherwise carry on
      true -> normalRecurse(remainingChars, {xc, yc + 1}, bigAcc, grid)
    end
  end

  def returnGearValue({xc, yc}, grid) do
    #check 8 surrounding squares
    #Top Row
    {tl, tr} = cond do
      #first row edge case
      xc == 0 ->
        {0, 0}

      #If top center is digit, only one number can be on top row (Top Left)
      checkDigit(elem(elem(grid, xc - 1), yc)) ->
        {parseNumber(grid, {xc-1, yc}), 0}

        #If top center isn't digit, potentially two numbers (Top Left & top right)
      !checkDigit(elem(elem(grid, xc - 1), yc)) ->
        {parseNumber(grid, {xc-1, yc - 1}), parseNumber(grid, {xc-1, yc + 1})}
    end

    #Middle Row
    ml = parseNumber(grid, {xc, yc - 1})
    mr = parseNumber(grid, {xc, yc + 1})


    #Bottom Row
    {bl, br} = cond do
      #bottom row edge case
      xc == tuple_size(grid) ->
        {0,0}

      #If bottom center is digit, only one number can be on top row (bottom Left)
      checkDigit(elem(elem(grid, xc + 1), yc)) ->
        {parseNumber(grid, {xc + 1, yc}), 0}

        #If bottom center isn't digit, potentially two numbers (Bottom Left & top right)
      !checkDigit(elem(elem(grid, xc + 1), yc)) ->
        {parseNumber(grid, {xc + 1, yc - 1}), parseNumber(grid, {xc + 1, yc + 1})}
    end

    values = [tl, tr, ml, mr, bl, br] |> Enum.filter(fn x -> x != 0 end)

    # values
    # |> IO.inspect(charlists: :as_lists)

    #IO.inspect(values)

    cond do
      # if only 2 non-zero numbers, multiply them and return
      length(values) == 2 ->
        values |> Enum.reduce(fn x, acc -> x * acc end)
      true -> 0
    end

  end

  def getSafeElement(grid, xc, yc) do
    cond do
      xc < 0 or yc < 0 -> "."
      xc >= tuple_size(grid) -> "."
      yc >= tuple_size(elem(grid,0)) -> "."
      true -> elem(elem(grid, xc), yc)
    end
  end

  def parseNumber(grid, {xc, yc}) do
    #recurse to left, then back right
    curr = getSafeElement(grid, xc, yc)
    cond do
      !checkDigit(curr) -> 0
       checkDigit(curr) -> recurseLeft(grid, {xc, yc - 1})
    end
  end

  def recurseLeft(grid, {x, y}) do
    curr = getSafeElement(grid, x, y)
    cond do
      !checkDigit(curr) -> recurseRight(grid, {x, y + 1}, "")
       checkDigit(curr) -> recurseLeft(grid, {x, y - 1})
    end
  end

  def recurseRight(grid, {x, y}, acc) do
    curr = getSafeElement(grid, x, y)
    cond do
      !checkDigit(curr) -> elem(Integer.parse(acc), 0)
       checkDigit(curr) -> recurseRight(grid, {x, y + 1}, acc <> curr)
    end
  end

  # def digitRecurse([], acc, _coord, bigAcc, _grid) do
  #   bigAcc + Integer.parse(acc)
  # end
  # def digitRecurse([currentChar | remainingChars], acc, {xc, yc}, bigAcc, grid) do
  #   cond do
  #     # Number continues
  #     checkDigit(currentChar) -> digitRecurse(remainingChars, acc <> currentChar, {xc, yc+1}, bigAcc, grid)
  #     # Number has touching symbol, add the total and continue parsing
  #     Util.checkSurroundingsForSymbols({xc, yc-1}, String.length(acc), grid) ->
  #       normalRecurse(remainingChars, {xc, yc+1}, bigAcc + elem(Integer.parse(acc), 0), grid)
  #     # Number discarded, continue parsing
  #     true ->
  #       normalRecurse(remainingChars, {xc, yc+1}, bigAcc, grid)
  #   end
  # end
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
|> Enum.map(fn {row, index} -> Util.normalRecurse(String.split(row, ""), {index, -1}, 0, grid) end)
|> Enum.sum()

# Util.checkSurroundingsForSymbols({5, 7}, 3)

# function to find numbers and applicable grid spaces?

#iterate
#  if digit and prior was . , add to list

#IO.puts(Util.checkSymbol(grid, {4, 8}))

IO.puts(output)

#File.write("day3_output", output |> Enum.join("\n"))
