defmodule Util do
  def grid(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn row -> String.split(row, "", trim: true) end)
  end

  #Choosing to make each spot responsible for what it'll energize.  TBD on how that goes
  def lookup_map(grid) do
    grid
    |> Enum.map(fn x -> Enum.with_index(x) end)
    |> Enum.with_index()
    |> Enum.map(fn {row, row_index} ->
      Enum.map(row, fn {val, col_index} ->
          get_spots_that_will_trigger({val, row_index, col_index}, grid)
        end)
      end)
  end

  def get_spots_that_will_trigger({val, row_index, col_index}, grid) do
    # case char, use char to look ahead and store what it would trigger (as row-index to match map keys) (store direction of triggering so /s are handled correctly)
    case val do
      "." -> %{char: val, row_index: row_index, col_index: col_index, prop_from_north: [], prop_from_south: [], prop_from_east: [], prop_from_west: []}
      "/" ->
        %{
          char: val,
          row_index: row_index,
          col_index: col_index,
          prop_from_north: prop_in_direction({row_index, col_index}, :east, grid, []),
          prop_from_south: prop_in_direction({row_index, col_index}, :west, grid, []),
          prop_from_east: prop_in_direction({row_index, col_index}, :north, grid, []),
          prop_from_west: prop_in_direction({row_index, col_index}, :south, grid, []),
        }
      "\\" ->
        %{
          char: val,
          row_index: row_index,
          col_index: col_index,
          prop_from_north: prop_in_direction({row_index, col_index}, :west, grid, []),
          prop_from_south: prop_in_direction({row_index, col_index}, :east, grid, []),
          prop_from_east: prop_in_direction({row_index, col_index}, :south, grid, []),
          prop_from_west: prop_in_direction({row_index, col_index}, :north, grid, []),
        }
      "-" ->
        east_west = prop_in_direction({row_index, col_index}, :east, grid, []) ++ prop_in_direction({row_index, col_index}, :west, grid, [])
        %{
          char: val,
          row_index: row_index,
          col_index: col_index,
          prop_from_north: east_west,
          prop_from_south: east_west
        }
      "|" ->
        north_south = prop_in_direction({row_index, col_index}, :north, grid, []) ++ prop_in_direction({row_index, col_index}, :south, grid, [])
        %{
          char: val,
          row_index: row_index,
          col_index: col_index,
          prop_from_east: north_south,
          prop_from_west: north_south,
        }
    end
    #
  end

  # Return array of elements in this direction that will be energized, don't propogate past /, \, perpindicular splitter, or edge of grid
  def prop_in_direction({row, col}, dir, grid, acc) do
    row_max = Enum.count(grid)
    col_max = Enum.count(hd(grid))
    # Still not sure of the cleanest way to avoid manually cond checking for these out of bounds cases
    # Feels like I should be pattern matching, but I don't think that's viable on variables like row_max?
    cond do
      dir == :north and row - 1 < 0 -> acc
      dir == :south and row + 1 >= row_max -> acc
      dir == :west and col - 1 < 0 -> acc
      dir == :east and col + 1 >= col_max -> acc
      true ->
        case dir do
          :north ->
            char = Enum.at(Enum.at(grid, row - 1), col)
            new_acc = acc ++ [{row - 1, col, dir}]
            case char do
              "-" -> new_acc
              "/" -> new_acc
              "\\" -> new_acc
              _ -> prop_in_direction({row - 1, col}, :north, grid, new_acc)
            end
          :south ->
            char = Enum.at(Enum.at(grid, row + 1), col)
            new_acc = acc ++ [{row + 1, col, dir}]
            case char do
              "-" -> new_acc
              "/" -> new_acc
              "\\" -> new_acc
              _ -> prop_in_direction({row + 1, col}, :south, grid, new_acc)
            end
          :west ->
            char = Enum.at(grid, row) |> Enum.at(col - 1)
            new_acc = acc ++ [{row, col - 1, dir}]
            case char do
              "|" -> new_acc
              "/" -> new_acc
              "\\" -> new_acc
              _ -> prop_in_direction({row, col - 1}, :west, grid, new_acc)
            end
          :east ->
            char = Enum.at(grid, row) |> Enum.at(col + 1)
            new_acc = acc ++ [{row, col + 1, dir}]
            case char do
              "|" -> new_acc
              "/" -> new_acc
              "\\" -> new_acc
              _ -> prop_in_direction({row, col + 1}, :east, grid, new_acc)
            end
        end
      end
  end

  def solve_puzzle(grid) do
    # start by getting east triggers of first square, recurse through list from there
    #start_list = Map.get(Enum.at(Enum.at(grid, 0), 1), :prop_from_west)
    {start_list, pre_traversed_map} = start_row(Enum.with_index(Enum.at(grid,0)), %{})
    recursive_solve(grid, start_list, pre_traversed_map)
  end

  def start_row([{current, col}|remaining], acc_map) do
    curr_char = Map.get(current, :char)
    key = "0-" <> Integer.to_string(col)
    new_map = Map.put(acc_map, key, :east)
    case curr_char do
      "." -> start_row(remaining, new_map)
      _ -> {[{0, col, :east}], acc_map} #return unmodified map since recursive solve will start here
    end
  end

  def recursive_solve(_grid, [], acc) do
    acc
  end
  def recursive_solve(_grid, [{nil, _col, _dir}|_remaining], acc) do
    acc
  end
  def recursive_solve(_grid, [{_row, nil, _dir}|_remaining], acc) do
    acc
  end
  def recursive_solve(grid, [spot|remaining], acc) do
    key = Integer.to_string(elem(spot, 0)) <> "-" <> Integer.to_string(elem(spot, 1))
    pre_traversed = Map.get(acc, key)
    grid_elem = Enum.at(Enum.at(grid, elem(spot, 0)), elem(spot,1))
    new_list = case elem(spot, 2) do
      :north -> Map.get(grid_elem, :prop_from_north, [])
      :south -> Map.get(grid_elem, :prop_from_south, [])
      :east -> Map.get(grid_elem, :prop_from_east, [])
      :west -> Map.get(grid_elem, :prop_from_west, [])
    end
    cond do
      pre_traversed == nil ->
        dir_list = Map.get(acc, key, [])
        recursive_solve(grid, remaining ++ new_list, Map.put(acc, key, dir_list ++ [elem(spot, 2)]))
      pre_traversed != [] and Enum.any?(pre_traversed, fn x -> x == elem(spot, 2) end) ->
        recursive_solve(grid, remaining, acc)
      true ->
        dir_list = Map.get(acc, key, [])
        recursive_solve(grid, remaining ++ new_list,  Map.put(acc, key, dir_list ++ [elem(spot, 2)]) )
    end
  end

  # Visualize the path.  This is cooler to see than the final number answer and *invaluable* for debugging
  def demo_output(energized, grid) do
    energized
      |> Enum.reduce(grid, fn {k, _v}, acc ->
        [row|col_list] = String.split(k, "-", trim: true)
        col = String.to_integer(hd(col_list))
        List.update_at(acc, String.to_integer(row), fn r ->
          List.update_at(r, col, fn _x -> "#" end)
        end)
      end)
  end
end

defmodule Part2 do
  def solve_puzzle(grid) do
    generate_starting_lists(grid)
      |> Enum.map(fn {x, dir} -> traverse_opening_list(x, dir, grid, %{}) end)
      |> Enum.map(fn {start_list, pre_traversed_map} -> Util.recursive_solve(grid, start_list, pre_traversed_map) end)
  end

  #Get full row or column as list in correct direction for every edge point
  defp generate_starting_lists(grid) do
    max_row = Enum.count(grid) - 1
    max_col = Enum.count(hd(grid)) - 1
    verts = Enum.to_list(0..max_col)
      |> Enum.reduce([], fn col_val, acc ->
        south = {grid |> Enum.map(fn row -> Enum.at(row, col_val) end), :south}
        north = {Enum.reverse(grid) |> Enum.map(fn row -> Enum.at(row, col_val) end), :north}
        acc ++ [south] ++ [north]
      end)
    horizs = Enum.to_list(0..max_col)
      |> Enum.reduce([], fn row_val, acc ->
        east = {Enum.at(grid, row_val), :east}
        west = {Enum.reverse(Enum.at(grid, row_val)), :west}
        acc ++ [east] ++ [west]
      end)

    verts ++ horizs
  end

  # Recursively solve first row or column until we reach a character with propogation lists (anything not .)
  defp traverse_opening_list([], dir, _grid, acc_map) do
    {[{nil, nil, dir}], acc_map}
  end
  defp traverse_opening_list([current|remaining], dir, grid, acc_map) do
    row = Map.get(current, :row_index)
    col = Map.get(current, :col_index)
    curr_char = Map.get(current, :char)
    key = Integer.to_string(row) <> "-" <> Integer.to_string(col)
    new_map = Map.put(acc_map, key, [dir])
    case curr_char do
      "." -> traverse_opening_list(remaining, dir, grid, new_map)
      _ -> {[{row, col, dir}], acc_map} #return unmodified map since recursive solve will start here
    end
  end
end

# Part 1
# grid = File.read!("input")
#   |> Util.grid()
# energized = Util.lookup_map(grid)
#   |> Util.solve_puzzle()

# demo = Util.demo_output(energized, grid)
# output = energized
#   |> Enum.count()

# IO.inspect(demo)
# IO.inspect(output)

part2 = File.read!("input")
  |> Util.grid()
  |> Util.lookup_map()
  |> Part2.solve_puzzle()
  |> Enum.map(fn x -> Enum.count(x) end )
  |> Enum.max()

IO.inspect(part2)
