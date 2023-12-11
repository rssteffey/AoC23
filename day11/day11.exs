defmodule Util do

  def grid(inputFile) do
    inputFile
    |> String.split("\n", trim: true)
    |> Enum.map(fn row -> String.split(row, "", trim: true) end)
  end

  def expandSpacetime(inputGrid) do
    # Expand cols
    bigBang = List.first(inputGrid)
    |> Enum.with_index()
    |> Enum.filter(fn {_char, idx} -> checkColAllSpace(idx, inputGrid) end)
    |> Enum.map(fn {_, idx} -> idx end)
    |> Enum.reverse()
    |> Enum.reduce(inputGrid, fn idx, acc ->
      acc
       |> Enum.map(fn row -> List.insert_at(row, idx, ".") end)
    end)

    # Expand Rows
    bigBang
    |> Enum.with_index()
    |> Enum.filter(fn {row, idx} -> Enum.all?(row, fn x -> x == "." end ) end)
    |> Enum.map(fn {_, idx} -> idx end)
    |> Enum.reverse()
    |> Enum.reduce(bigBang, fn idx, acc ->
      newRow = Enum.to_list(0..(Enum.count(List.first(bigBang)) - 1)) |> Enum.map(fn _ -> "." end)
      List.insert_at(acc, idx, newRow)
    end)
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

  def calcDistances(galaxies) do
    calcDistances(0, galaxies)
  end
  def calcDistances(acc, []) do
    acc
  end
  def calcDistances(acc, [galaxy|rest]) do
    activeDists = Enum.map(rest, fn dest ->
      getDist(galaxy, dest)
    end)
    |> Enum.sum()

    calcDistances(acc + activeDists, rest)
  end

  defp getDist({_galA, rowA, colA}, {_galB, rowB, colB}) do
    Kernel.abs(rowA - rowB) + Kernel.abs(colA - colB)
  end

  defp checkColAllSpace(colIdx, inputGrid) do
    Enum.all?(inputGrid, fn row -> elem(Enum.fetch(row, colIdx),1) == "." end)
  end

end

defmodule Part1 do

end

defmodule Part2 do

end

galaxies = File.read!("input")
  |> Util.grid()
  |> Util.expandSpacetime()
  |> Util.getGalaxies()

output = Util.calcDistances(galaxies)


# Part 1
#output = Part1.followPipe(start, {nil, nil}, grid, 0)

IO.inspect(output)


# Part 2
