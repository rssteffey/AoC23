defmodule Util do
  def createNode(nodeString) do
    # AAA = (BBB, BBB)
    [name | leftRight] = String.split(nodeString, " = ", trim: true)
    [left| rightList] = hd(leftRight)
    |> String.replace("(", "")
    |> String.replace(")", "")
    |> String.split(", ", trim: true)

    {name, {name, left, hd(rightList)}}
  end

  def getNextNode(direction, currentNode, nodemap) do
    cond do
      direction == "L" ->
        Map.get(nodemap, elem(currentNode, 1))
      direction == "R" ->
        Map.get(nodemap, elem(currentNode, 2))
      true ->
        "error"
    end
  end

  # Out of directions, repopulate with ogDirections
  def followDirections([], currNode, map, stepCount, ogDirections) do
    followDirections(ogDirections, currNode, map, stepCount, ogDirections)
  end
  def followDirections(directions, currNode, map, stepCount, ogDirections) do
    cond do
      elem(currNode, 0) == "ZZZ" ->
        stepCount
      stepCount >= 230884 ->
        "Cycle ensured - check input"
      true ->
        [direction| restOfDirections] = directions
        next = getNextNode(direction, currNode, map)
        followDirections(restOfDirections, next, map, stepCount + 1, ogDirections)
    end
  end
end

defmodule Part2 do
  def startsWithA("A" <> rest) do true end
  def startsWithA(_) do false end
  def startsWithZ("Z" <> rest) do true end
  def startsWithZ(_) do false end

  # Get the cycle length of each ghost's route
  def countToZ([], currNode, map, stepCount, ogDirections) do
    countToZ(ogDirections, currNode, map, stepCount, ogDirections)
  end
  def countToZ(directions, currNode, map, stepCount, ogDirections) do
    cond do
      startsWithZ(String.reverse(elem(currNode, 0))) ->
        stepCount
      true ->
        [direction| restOfDirections] = directions
        next = Util.getNextNode(direction, currNode, map)
        countToZ(restOfDirections, next, map, stepCount + 1, ogDirections)
    end
  end

	def lcm(0, 0), do: 0
	def lcm(a, b), do: (a*b) / Integer.gcd(a,b)
end

[directions|nodestring] = File.read!("input")
|> String.split("\n\n", trim: true)

nodes = hd(nodestring)
|> String.split("\n", trim: true)
|> Enum.map(&Util.createNode/1)

nodeMap = nodes |> Map.new()

dirMap = directions
|> String.split("", trim: true)

startNodes = nodes
|> Enum.filter(fn x -> Part2.startsWithA(String.reverse(elem(x, 0))) end)

numerators = startNodes
|> Enum.map(fn x -> Part2.countToZ(dirMap, elem(x, 1), nodeMap, 0, dirMap) end)

IO.inspect(numerators)

[firstMultiple|otherMultiples] = numerators

lcm = otherMultiples
|> Enum.reduce(firstMultiple, fn x, acc -> Kernel.round(Part2.lcm(x, acc)) end)

IO.inspect(lcm)
