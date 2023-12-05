defmodule Util do
  # Leaving the below commented out code as a testament to 1am brain not taking time to find the algorithm

  # def updateMapFromRow({dst, src, rng}, myMap) do
  #     destStart = String.to_integer(dst)
  #     sourceStart = String.to_integer(src)
  #     range = String.to_integer(rng)

  #     sources = sourceStart..(sourceStart + range - 1)
  #     destinations = destStart..(destStart + range - 1)
  #     recursiveMapUpdateFromRow(Enum.to_list(sources), Enum.to_list(destinations), myMap)
  # end

  # defp recursiveMapUpdateFromRow([], _, oldMap) do
  #   oldMap
  # end
  # defp recursiveMapUpdateFromRow(sources, destinations, oldMap) do
  #   [source|remainingS] = sources
  #   [dest|remainingD] = destinations
  #   newMap = Map.update(oldMap, source, dest, fn _y -> dest end)
  #   recursiveMapUpdateFromRow(remainingS, remainingD, newMap)
  # end

  # def generateMapFromChunk(input) do
  #     [mapName|mapVals] = String.split(input, ":")

  #     cleanMap = %{name: mapName}

  #     String.split(hd(mapVals), "\n", trim: true)
  #     |> Enum.map(fn x -> List.to_tuple(String.split(x, " ", trim: true)) end)
  #     |> Enum.reduce(cleanMap, fn x, acc -> updateMapFromRow(x, acc) end)
  # end

  # def seedToLocation(seedString, mapStack) do
  #   seed = String.to_integer(seedString)
  #   Enum.reduce(mapStack, seed, fn map, val -> Map.get(map, val, val) end)
  # end

  # Begin actual functional and very simple solution:

  def betterSeedToLocation(seedString, mapChunks) do
    seed = seedString
    mapChunks
    |> Enum.reduce(seed, fn x, acc -> createTuplesFromChunks(acc, x) end)
  end

  defp getSeedTransformFromRow({dst, src, rng}, seed) do
    dest = String.to_integer(dst)
    source = String.to_integer(src)
    range = String.to_integer(rng)
    cond do
      seed >= source and seed < (source + range) ->
        val = seed + (dest - source)
        val
      true ->
        seed
    end
  end

  defp createTuplesFromChunks(input, mapChunk) do
    [_mapName|mapVals] = String.split(mapChunk, ":", trim: true)

      String.split(hd(mapVals), "\n", trim: true)
      |> Enum.map(fn x -> List.to_tuple(String.split(x, " ", trim: true)) end)
      |> Enum.map(fn x -> getSeedTransformFromRow(x, input) end)
      |> Enum.reduce(input, fn x, acc ->
        cond do
          x != acc and x != input -> x
          true -> acc
        end
      end)
  end

  def locationToSeed(loc, maps, seedList) do
    seed = maps
    |> Enum.reduce(loc, fn x, acc -> tupleMapper(acc, x) end)

    cond do
      seedInSeedList(seed, seedList) -> {seed, loc}
      true -> locationToSeed(loc + 1, maps, seedList)
    end
  end

  defp tupleMapper(input, mapChunk) do
    [_mapName|mapVals] = String.split(mapChunk, ":", trim: true)

      String.split(hd(mapVals), "\n", trim: true)
      |> Enum.map(fn x -> List.to_tuple(String.split(x, " ", trim: true)) end)
      |> Enum.map(fn x -> getReverseTransformFromRow(x, input) end)
      |> Enum.reduce(input, fn x, acc ->
        cond do
          x != acc and x != input -> x
          true -> acc
        end
      end)
  end

  # recursive check if seed is valid
  defp seedInSeedList(_seed, []) do
    false
  end
  defp seedInSeedList(seed, seedList) do
    [startString|restA] = seedList
    [endString|rest] = restA

    startRange = String.to_integer(startString)
    endRange = String.to_integer(endString)

    cond do
      seed >= startRange and seed < (startRange + endRange) ->
        true
      true -> seedInSeedList(seed, rest)
    end
  end

  defp getReverseTransformFromRow({dst, src, rng}, loc) do
    dest = String.to_integer(dst)
    source = String.to_integer(src)
    range = String.to_integer(rng)
    cond do
      loc >= dest and loc < dest + range ->
        source + (loc - dest)
      true ->
        loc
    end
  end
end


file = File.read!("day5_input")

[seedString|otherMaps] = file
  |> String.split("\n\n", trim: true)

#Part 1
# [_|seedList] = String.split(seedString, ":")
# seeds = String.split( hd(seedList), " ", trim: true)

# result = seeds
#   |> Enum.map(fn x -> Util.betterSeedToLocation(x, otherMaps) end)
#   |> Enum.min()

# IO.inspect(result)

#Part 2 (Reverse Naive)
[_|seedList] = String.split(seedString, ":", trim: true)
seeds = String.split( hd(seedList), " ", trim: true)
result = Util.locationToSeed(0, Enum.reverse(otherMaps), seeds)
IO.inspect(result)
