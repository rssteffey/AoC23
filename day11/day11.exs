defmodule Util do
  # Change to "2" for Part 1
  @multiplier 1000000

  def grid(inputFile) do
    inputFile
    |> String.split("\n", trim: true)
    |> Enum.map(fn row -> String.split(row, "", trim: true) end)
  end

  def expandSpacetime(inputGrid) do
    # Expand cols
    colSplosion = List.first(inputGrid)
    |> Enum.with_index()
    |> Enum.filter(fn {_char, idx} -> checkColAllSpace(idx, inputGrid) end)
    |> Enum.map(fn {_, idx} -> idx end)

    # Expand Rows
    rowSplosion = inputGrid
    |> Enum.with_index()
    |> Enum.filter(fn {row, idx} -> Enum.all?(row, fn x -> x == "." or x == "B" end ) end)
    |> Enum.map(fn {_, idx} -> idx end)

    {rowSplosion, colSplosion}
  end

  def getGalaxies(inputGrid) do
    indexed = inputGrid
    |> Enum.map( fn row -> Enum.with_index(row) end)
    |> Enum.with_index()
    |> Enum.map(fn {row, rowIdx} ->
      Enum.filter(row, fn {x, colIdx} -> x == "#" end)
      |> Enum.map(fn {galaxy, colIdx} -> {galaxy, rowIdx, colIdx} end)
    end)
    |> List.flatten()
  end

  # Recurse through all Galaxy pairs while summing
  def calcDistances(acc, [], _) do
    acc
  end
  def calcDistances(acc, [galaxy|rest], gaps) do
    activeDists = Enum.map(rest, fn dest ->
      getDist(galaxy, dest, gaps)
    end)
    |> Enum.sum()

    calcDistances(acc + activeDists, rest, gaps)
  end

  defp getDist({_galA, rowA, colA}, {_galB, rowB, colB}, {expansionRows, expansionCols}) do
    rowGaps = expansionRows
    |> Enum.filter(fn idx -> (idx < rowA and idx > rowB) or (idx > rowA and idx < rowB) end)
    |> Enum.count

    colGaps = expansionCols
    |> Enum.filter(fn idx -> (idx < colA and idx > colB ) or (idx > colA and idx < colB ) end)
    |> Enum.count

    Kernel.abs(rowA - rowB) + Kernel.abs(colA - colB) + ((@multiplier - 1) * rowGaps) + ((@multiplier - 1) * colGaps)
  end

  defp checkColAllSpace(colIdx, inputGrid) do
    Enum.all?(inputGrid, fn row -> elem(Enum.fetch(row, colIdx),1) == "." end)
  end
end

space = File.read!("input")
  |> Util.grid()
remnantsOfBigBang = Util.expandSpacetime(space)
galaxies = Util.getGalaxies(space)
output = Util.calcDistances(0, galaxies, remnantsOfBigBang)

IO.inspect(output)
