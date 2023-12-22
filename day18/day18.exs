defmodule Util do
  def dig_trench([], _prior, trench) do
    trench
  end
  def dig_trench([instruction|remaining], {prior_row, prior_col}, trench) do
    [dir, count, color| _space] = String.split(instruction, " ", trim: true)
    dug_trench = Enum.to_list(1..String.to_integer(count))
      |> Enum.reduce(trench, fn x, acc ->
        new_hole = case dir do
          "D" -> %{row: prior_row + x, col: prior_col, color: color}
          "U" -> %{row: prior_row - x, col: prior_col, color: color}
          "L" -> %{row: prior_row, col: prior_col - x, color: color}
          "R" -> %{row: prior_row, col: prior_col + x, color: color}
        end
      acc ++ [new_hole]
      end)
      last_hole = hd(Enum.reverse(dug_trench))
    dig_trench(remaining, {Map.get(last_hole, :row), Map.get(last_hole, :col)}, dug_trench)
  end

  # Create a 0-based grid for easier plotting
  def generate_grid_to_size(trench) do
    left_bound = trench |> Enum.map(fn x -> Map.get(x, :col) end) |> Enum.min()
    right_bound = trench |> Enum.map(fn x -> Map.get(x, :col) end) |> Enum.max()
    upper_bound = trench |> Enum.map(fn x -> Map.get(x, :row) end) |> Enum.min()
    lower_bound = trench |> Enum.map(fn x -> Map.get(x, :row) end) |> Enum.max()

    width_offset = right_bound - left_bound
    height_offset = lower_bound - upper_bound

    grid = Enum.to_list(0..height_offset)
      |> Enum.map(fn row_idx ->
        Enum.to_list(0..width_offset)
          |> Enum.map(fn col_idx ->
            trench_spot = Enum.find(trench, fn x -> Map.get(x, :row) - upper_bound == row_idx and Map.get(x, :col) - left_bound == col_idx end)
            case trench_spot do
              nil -> %{row: row_idx, col: col_idx, char: ".", color: nil}
              _ -> %{row: row_idx, col: col_idx, char: "#", color: Map.get(trench_spot, :color)}
            end
          end)
      end)

    grid
  end

  #Just going for count here
  def fill(start, size, path) do
    path = MapSet.new(path)
    frontier = [start]
    explored = MapSet.new(frontier) |> MapSet.union(path)
    fill(%{}, size, frontier, explored)
  end

  defp fill(_, _, [], explored) do
    explored
  end

  defp fill(map, {height, width} = size, [{y0, x0} | rest], explored) do
    neighbors =
      [{y0 - 1, x0}, {y0, x0 - 1}, {y0 + 1, x0}, {y0, x0 + 1}]
      |> Enum.filter(fn {y1, x1} = coord ->
        y1 >= 0 - 112 and
          y1 < height - 112 and
          x1 >= 0 - 63 and
          x1 < width - 63 and
          not MapSet.member?(explored, coord)
      end)

    frontier = neighbors ++ rest
    explored = MapSet.new(neighbors) |> MapSet.union(explored)
    fill(map, size, frontier, explored)
  end

  # Print Helper
  def printable_grid(grid) do
    Enum.map(grid, fn row ->
      Enum.map(row, fn item ->
        Map.get(item, :char)
      end)
    end)
  end

  # --- Part 2 : Infinitely better -----

  # Look ma, I'm patterning!
  def hex_to_instruction(line) do
    [_,_,hex] = String.split(line, " ", trim: true)
    hex_val = String.replace(hex, ["(", ")", "#"], "")
    {dist, _err} = Integer.parse(String.slice(hex_val, 0, 5), 16)
    dir = String.to_integer(String.slice(hex_val, 5, 1))

    {dir, dist}
  end

  # I think this is viable without ever drawing anything out really?
  # Best explanation of the reverse work to get here:
  #    - Use our current east/west position and multiply the various Y levels out by that much (or vise versa I guess, but choose X with me)
  #    - kind of like an integral, but specifically when we first learned them by approximating a bunch of rectangle areas under a curve?
  #    - Except this curve already happens to be a bunch of rectangles, so we're set!
  #    - The -1 lookup map for left and down are what allow this to work, we're essentially overwriting old values for each new chunk traversed
  #    - Geometric subtraction, if vector illustration apps are more your language
  #    - *Update: an hour of trial and error later, I think my math works from the center of each line, which ends up leaving me half a block short on any side, so tack that on
  #    -  or better put - this line's thickness needs to be included in the area, but area overlapping the inside is already included in the integral, so just add the outside
  def part2_easy_solve(instructions) do
    # Stolen shamelessly from prior Raspberry Pi arcade input direction shorthand, but weirdly 1:1 mapping applicable here
    dir_lookup = %{0 => {1,0}, 1 => {0,1}, 2 => {-1,0}, 3 => {0,-1}}

    instructions
      |> Enum.map(fn {dir, dist} -> {Map.get(dir_lookup, dir), dist} end)
      |> Enum.reduce({0, 0}, fn {{x, y}, dist}, {position_acc, answer_acc} ->
        new_pos = position_acc + (x * dist)
        new_ans = answer_acc + ((y * dist) * new_pos + (dist / 2))
        {new_pos, new_ans}
      end)
  end
end

# Part 1
# instructions = File.read!("input")
#   |> String.split("\n", trim: true)
# trench = Util.dig_trench(instructions, {0, 0}, [%{row: 0, col: 0, color: nil}])
# grid = Util.generate_grid_to_size(trench)

# simple_trench = Enum.map(trench, fn x -> {Map.get(x, :row), Map.get(x, :col)} end)

# filled = Util.fill({15,74}, {Enum.count(grid), Enum.count(hd(grid))}, simple_trench) #manually setting start point within curve

# IO.inspect(Enum.count(filled))


# Absurdly simple Part 2?
instructions = File.read!("input")
  |> String.split("\n", trim: true)
  |> Enum.map(fn line -> Util.hex_to_instruction(line) end)
{_, answer} = Util.part2_easy_solve(instructions)

# This may have to be ABS()ed for all input cases?
IO.inspect(answer + 1) # I assume the off by one is for my starting space?  Still deciding
