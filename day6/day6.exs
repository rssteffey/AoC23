
defmodule Util do
  def createRacesPart1(input) do
      [time|distance] = input

      [_cat|timeString] = String.split(time, ":")
      [_cat|distString] = String.split(hd(distance), ":")
      times = String.split(hd(timeString), " ", trim: true);
      dists = List.to_tuple(String.split(hd(distString), " ", trim: true));

      output = times
      |> Enum.with_index(fn element, index -> {index, element} end)
      |> Enum.map(fn {i, x} -> %{time: String.to_integer(x), dist: String.to_integer(elem(dists, i))} end)

      IO.inspect(output)
  end

  def createRacePart2(input) do
    [time|distance] = input

    [_cat|timeString] = String.split(time, ":")
    [_cat|distString] = String.split(hd(distance), ":")
    times = String.split(hd(timeString), " ", trim: true);
    time = String.to_integer(Enum.join(times, ""))
    dists = String.split(hd(distString), " ", trim: true);
    dist = String.to_integer(Enum.join(dists, ""))

    %{time: time, dist: dist}
end

  def countWinningTimes(race) do
    time = Map.get(race, :time, 0)
    dist = Map.get(race, :dist, 0)

    #start naive
    result = Enum.to_list(1..(time-1))
    |> Enum.map(fn x -> x * (time - x) end) #distance
    |> Enum.map(fn x -> cond do #compare against record
        x > dist -> 1
        true -> 0
      end
    end)
    |> Enum.sum()

    result
  end

end

file = File.read!("input")

games = file
|> String.split("\n", trim: true)

# Part 1
# results = Util.createRacesPart1(games)
# |> Enum.map(&Util.countWinningTimes/1)
# |> Enum.product()

# IO.inspect(results)

# Part 2
race = Util.createRacePart2(games)
results = Util.countWinningTimes(race)

IO.inspect(results)
