defmodule Util do

  # Probably should be larger, but the input set looks small enough and eh
  @powersOfTwo [1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768, 65536, 131072, 262144, 524288, 1048576, 2097152, 4194304, 8388608]

  def grid(input_grid) do
    input_grid
    |> String.split("\n", trim: true)
    |> Enum.map(fn row -> String.split(row, "", trim: true) end)
  end

  def find_reflection_value(grid) do
    IO.puts("Grid:")
    IO.inspect(grid)
    {rows, cols} = grid_to_checksums(grid)

    IO.inspect({rows, cols})

    #Should probably do this more dynamically, but I just want to be done
    # Find all pairs in this list that are only a power of two apart
    # generate a new list and calculate for each one
    # Use the smallest?
    # Use OG values as skips when re-running reflection

    # TEST CASE DIFFERENT BY 8 AND 16 WHICH MEANS 8 WORKS

    row_modifications = modify_rows(rows |> Enum.with_index(), [])
    col_modifications = modify_rows(cols |> Enum.with_index(), [])

    IO.puts("Mods:")
    IO.inspect(row_modifications)
    IO.inspect(col_modifications)

    normal_row_val = start_reflection_value_from_sums(rows)
    normal_col_val = start_reflection_value_from_sums(cols)

    IO.puts("Normal Sums:")
    IO.inspect(normal_row_val, charlists: :as_lists)
    IO.inspect(normal_col_val, charlists: :as_lists)

    row_mod_sums = row_modifications
      |> Enum.map(fn val_change ->
        List.update_at(rows, Map.get(val_change, :change_index, nil), fn _x -> Map.get(val_change, :match_val, nil) end)
      end)
      |> Enum.map(fn new_grid -> start_reflection_value_from_sums(new_grid, normal_row_val) end)

    col_mod_sums = col_modifications
      |> Enum.map(fn val_change ->
        List.update_at(cols, Map.get(val_change, :change_index, nil), fn _x -> Map.get(val_change, :match_val, nil) end)
      end)
      |> Enum.map(fn new_grid ->
        start_reflection_value_from_sums(new_grid, normal_col_val)
      end)

    IO.puts("New Sums:")
    IO.inspect(row_mod_sums, charlists: :as_lists)
    IO.inspect(col_mod_sums, charlists: :as_lists)

    IO.puts("Results:")
    row_res = row_mod_sums
      |> Enum.min( fn -> 0 end)

    col_res = col_mod_sums
      |> Enum.min(fn -> 0 end)

    IO.inspect({row_res, col_res})

    output = cond do
      #normal_row_val == Enum.count(grid) and normal_col_val == Enum.count(hd(grid)) -> 10000000000
      #row_res == Enum.count(grid) and col_res == Enum.count(hd(grid)) -> 10000000000
      row_res == Enum.count(grid) -> col_res
      row_res == [] -> col_res
      row_res == nil -> col_res
      row_res == 0 -> col_res
      true -> row_res * 100
    end
     IO.puts("Val:")
    IO.inspect(output)
    output
  end

  defp modify_rows([], acc) do
    acc
  end
  defp modify_rows([{checksum, idx}|remaining], acc) do
    rows = remaining
      |> Enum.filter(fn {sum, _sum_idx} ->
          Enum.any?(@powersOfTwo, fn x -> x == Bitwise.bxor(checksum, sum)  end)
        end )
      |> Enum.map(fn {x, sum_idx} -> %{match_val: checksum, val_to_change: x, change_index: sum_idx} end)

    modify_rows(remaining, acc ++ rows)
  end

  defp grid_to_checksums(grid) do
    row_sums = grid
      |> Enum.map(fn row -> list_to_sum(row) end)

    col_sums = Enum.to_list(0..(Enum.count(hd(grid)) - 1))
      |> Enum.map(fn col_index ->
        Enum.reduce(grid, [], fn row, acc ->
          acc ++ [elem(Enum.fetch(row, col_index), 1)]
        end)
      end)
      |> Enum.map(fn col -> list_to_sum(col) end)

    {row_sums, col_sums}
  end

  def list_to_sum(row) do
    Enum.map(row, fn x ->
      case x do
        "#" -> "1"
        "." -> "0"
      end
    end)
    |> Enum.reduce(<<>>, fn x, acc -> acc <> x end)
    |> String.to_integer(2)
  end

  def start_reflection_value_from_sums([next|remaining], exclusion_val \\ -1) do
      find_reflection_value_from_sums(exclusion_val, [next], remaining, [])
  end

  # Reflection reverse ended without needing to undo
  def find_reflection_value_from_sums(exclusion_val, [], _remaining, undo) do
    Enum.count(undo)
  end

  # Reflection ended (or potentially just went through the entire string without a reflection, tbd)
  def find_reflection_value_from_sums(exclusion_val, checked, [], undo) do
    Enum.count(checked) + Enum.count(undo)
  end

  # Forward check
  def find_reflection_value_from_sums(exclusion_val, [last_checked|checked], [next|remaining], []) do
    cond do
      next == last_checked and exclusion_val !== (Enum.count(checked)+1) -> find_reflection_value_from_sums(exclusion_val, checked, remaining, [last_checked])
      true -> find_reflection_value_from_sums(exclusion_val, [next] ++ [last_checked|checked], remaining, [])
    end
  end

  # Reverse check (Mapping back over reflection)
  def find_reflection_value_from_sums(exclusion_val, [last_checked|checked], [next|remaining], [undo|undo_stack]) do
    cond do
      # If match, keep going backwards
      next == last_checked -> find_reflection_value_from_sums(exclusion_val, checked, remaining, [last_checked] ++ [undo|undo_stack])
      # If not a match, this isn't the reflection plane.  Undo back up through the stack
      true -> find_reflection_value_from_sums(exclusion_val, [last_checked|checked], [next|remaining], [undo|undo_stack], [undo|undo_stack])
    end
  end

  # Redoing an incorrect reflection (existence of redo stack) ALL the way back to the misleading point
  def find_reflection_value_from_sums(exclusion_val, checked, [next|remaining], [], []) do
    # After redo, skip the check for the next vals
    find_reflection_value_from_sums(exclusion_val, [next] ++ checked, remaining, [])
  end
  def find_reflection_value_from_sums(exclusion_val, checked, [next|remaining], [undo|undo_stack], [redo|redo_stack]) do
    find_reflection_value_from_sums(exclusion_val, [undo] ++ checked, [redo] ++ [next|remaining], undo_stack, redo_stack)
  end

end

answer = File.read!("input")
  |> String.split("\n\n")
  |> Enum.map(fn x -> Util.grid(x) end)
  |> Enum.map(fn x -> Util.find_reflection_value(x) end)
  |> Enum.sum()

IO.inspect(answer)
