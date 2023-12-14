defmodule Util do

  @target_cycle 1000000000

  def grid(input_grid) do
    input_grid
    |> String.split("\n", trim: true)
    |> Enum.map(fn row -> String.split(row, "", trim: true) end)
  end

  def spin_cycle(grid, grid_history) do
    drunk_grid = grid
    |> shift_rocks(:north)
    |> shift_rocks(:west)
    |> shift_rocks(:south)
    |> shift_rocks(:east)

    # Return tuple of new grid, plus new history
    {drunk_grid, [get_grid_state_as_ternary_list(drunk_grid)|grid_history]}
  end

  def shift_rocks(grid, dir) do
    case dir do
      :west -> shift_rocks_west(grid)
      :south ->
        grid
        |> rotate_matrix_clockwise()
        |> shift_rocks_west()
        |> rotate_matrix_clockwise()
        |> rotate_matrix_clockwise()
        |> rotate_matrix_clockwise()
      :east ->
          grid
          |> rotate_matrix_clockwise()
          |> rotate_matrix_clockwise()
          |> shift_rocks_west()
          |> rotate_matrix_clockwise()
          |> rotate_matrix_clockwise()
      :north ->
          grid
          |> rotate_matrix_clockwise()
          |> rotate_matrix_clockwise()
          |> rotate_matrix_clockwise()
          |> shift_rocks_west()
          |> rotate_matrix_clockwise()
    end
  end

  # Transpose, then reverse the lines because for some reason they get flipped.  Who knows
  def rotate_matrix_clockwise(grid) do
    grid
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&Enum.reverse/1)
  end

  def shift_rocks_west(grid) do
    #always shift West (rotation will handle rest)
    grid
    |> Enum.map(fn x -> slide_row(x, 0, -1, x) end)
  end

  def slide_row([], _idx, _last_wall, final_row) do
    final_row
  end
  def slide_row([val|remaining], index, last_wall_idx, mod_row) do
    new_wall_idx = case val do
      "#" -> index
      "." -> last_wall_idx
      "O" -> last_wall_idx
    end

    new_row = case val do
      "O" -> mod_row
        |> List.delete_at(index)
        |> List.insert_at(last_wall_idx + 1, "O")
      "." -> mod_row
      "#" -> mod_row
    end

    slide_row(remaining, index + 1, new_wall_idx, new_row)
  end

  def calculate_load(grid) do
    grid
    |> Enum.with_index()
    |> Enum.map(fn {row, index} ->
      row_val = Enum.count(grid) - index
      rock_count = Enum.filter(row, fn x -> x == "O" end)
        |> Enum.count()
      row_val * rock_count
    end)
    |> Enum.sum()
  end

  # Part 2

  def cycle_length(grid, pastGrids) do
    # If current grid state (after one full spin-cycle) matches a past state, that's a cycle, baby
    # pastGrids length - cycle index gives us the cycle length
    match = pastGrids
    |> Enum.with_index()
    |> Enum.find(nil, fn {x, idx} -> grid_matches_grid(get_grid_state_as_ternary_list(grid), x) end)

    case match do
      nil -> 0
      _ -> elem(match, 1) + 1
    end

  end

  # Stealing this from yesterday's reflection work to minimize storage
  def get_grid_state_as_ternary_list(grid) do
    grid
      |> Enum.map(fn x -> List.to_string(x) end)
      |> Enum.map(&String.replace(&1, ".", "0"))
      |> Enum.map(&String.replace(&1, "#", "1"))
      |> Enum.map(&String.replace(&1, "O", "2"))
      |> Enum.map(&String.to_integer(&1, 3))
  end

  def grid_matches_grid(ternary_grid_A, ternary_grid_B) do
    MapSet.new(ternary_grid_B) |> MapSet.subset?(MapSet.new(ternary_grid_A))
  end

  # Emergency escape
  def spin_until_cycle_found(_grid, 10000, _cycle_length) do
    IO.puts("broke early")
  end
  def spin_until_cycle_found({grid, grid_history}, count, 0) do
    {new_grid, new_history} = spin_cycle(grid, grid_history)
    cyc = cycle_length(new_grid, grid_history)
    spin_until_cycle_found({new_grid, new_history}, count + 1, cyc)
  end
  # Cycle found - mod then manually run the remaining spins to find our answer
  def spin_until_cycle_found({grid, _history}, count, cycle_length) do
    rem = rem(@target_cycle - count, cycle_length)
    new_grid = run_spin_x_more_times(grid, rem)
  end

  defp run_spin_x_more_times(grid, x) do
    final_grid = Enum.to_list(1..x)
      |> Enum.reduce(grid, fn _x, acc ->
        {new_grid, _hist} = spin_cycle(acc, [])
        new_grid
      end)
    final_grid
  end
end

# Part 1
# output = File.read!("input")
#   |> Util.grid()
#   |> Util.shift_rocks(:north)
#   |> Util.calculate_load()

# Part 2
grid = File.read!("input")
  |> Util.grid()

very_nauseous_grid = Util.spin_until_cycle_found({grid, []}, 0, 0)

output = very_nauseous_grid
  |> Util.calculate_load()

IO.inspect(output, charlists: :as_lists)
