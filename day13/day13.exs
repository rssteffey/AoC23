defmodule Util do

  def grid(inputGrid) do
    inputGrid
    |> String.split("\n", trim: true)
    |> Enum.map(fn row -> String.split(row, "", trim: true) end)
  end

  def findReflectionValue(grid) do
    {rows, cols} = gridToChecksums(grid)

    rowVal = startReflectionValueFromSums(rows)
    colVal = startReflectionValueFromSums(cols)

    cond do
      rowVal == Enum.count(grid) -> colVal
      true -> rowVal * 100
    end
  end

  defp gridToChecksums(grid) do
    rowSums = grid
      |> Enum.map(fn row -> listToSum(row) end)

    colSums = Enum.to_list(0..(Enum.count(hd(grid)) - 1))
      |> Enum.map(fn colIndex ->
        Enum.reduce(grid, [], fn row, acc ->
          acc ++ [elem(Enum.fetch(row, colIndex), 1)]
        end)
      end)
      |> Enum.map(fn col -> listToSum(col) end)

    {rowSums, colSums}
  end

  def listToSum(row) do
    Enum.map(row, fn x ->
      case x do
        "#" -> 1
        "." -> 0
      end
    end)
    |> Enum.map(fn x -> <<x::1>> end)
    |> Enum.reduce(<<>>, fn x, acc -> <<acc::bitstring, x::bitstring>> end)
  end

  def startReflectionValueFromSums([next|remaining]) do
      findReflectionValueFromSums([next], remaining, [])
  end

  # Reflection reverse ended without needing to undo
  def findReflectionValueFromSums([], remaining, undo) do
    Enum.count(undo)
  end

  # Reflection ended (or potentially just went through the entire string without a reflection, tbd)
  def findReflectionValueFromSums(checked, [], undo) do
    Enum.count(checked) + Enum.count(undo)
  end

  # Forward check
  def findReflectionValueFromSums([lastChecked|checked], [next|remaining], []) do
    cond do
      next == lastChecked -> findReflectionValueFromSums(checked, remaining, [lastChecked])
      true -> findReflectionValueFromSums([next] ++ [lastChecked|checked], remaining, [])
    end
  end

  # Reverse check (Mapping back over reflection)
  def findReflectionValueFromSums([lastChecked|checked], [next|remaining], [undo|undoStack]) do
    cond do
      # If match, keep going backwards
      next == lastChecked -> findReflectionValueFromSums(checked, remaining, [lastChecked] ++ [undo|undoStack])
      # If not a match, this isn't the reflection plane.  Undo back up through the stack
      true -> findReflectionValueFromSums([lastChecked|checked], [next|remaining], [undo|undoStack], [undo|undoStack])
    end
  end

  # Redoing an incorrect reflection (existence of redo stack) ALL the way back to the misleading point
  def findReflectionValueFromSums(checked, [next|remaining], [], []) do
    # After redo, skip the check for the next vals
    findReflectionValueFromSums([next] ++ checked, remaining, [])
  end
  def findReflectionValueFromSums(checked, [next|remaining], [undo|undoStack], [redo|redostack]) do
    findReflectionValueFromSums([undo] ++ checked, [redo] ++ [next|remaining], undoStack, redostack)
  end

end

grids = File.read!("testInput")
  |> String.split("\n\n")
  |> Enum.map(fn x -> Util.grid(x) end)
  |> Enum.map(fn x -> Util.findReflectionValue(x) end)
  |> Enum.sum()

IO.inspect(grids, charlists: :as_lists)
