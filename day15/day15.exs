defmodule Util do
  def hash(instruction) do
    instruction
    |> Enum.reduce(0, fn x, acc ->
      new_val = acc + x
      mult_val = new_val * 17
      rem(mult_val, 256)
    end)
  end

  # Part 2
  # Reverse to pattern match on "-" or "=" (and unreverse to store label)
  def hashmap(instruction, boxes) do
    reverse_instruction = String.to_charlist(instruction) |> Enum.reverse()
    case reverse_instruction do
      [45|label] -> remove_lens(Enum.reverse(label), boxes)
      [lens_strength,61|label] -> store_lens({List.to_string([lens_strength]), Enum.reverse(label)}, boxes)
    end
  end

  def store_lens({lens, label}, boxes) do
    Map.update(boxes, hash(label), [{lens, label}], fn box_contents ->
      old_lens_idx = Enum.find_index(box_contents, fn {_lens, existing_label} -> existing_label == label end)
      case old_lens_idx do
        nil -> box_contents ++ [{lens, label}]
        _ -> List.update_at(box_contents, old_lens_idx, fn _x -> {lens, label} end)
      end
    end)
  end

  def remove_lens(label, boxes) do
    Map.update(boxes, hash(label), [], fn box_contents ->
      Enum.filter(box_contents, fn {_lens, old_label} ->
        old_label != label
      end)
    end)
  end

  def calculate_power(boxes) do
    Enum.map(boxes, fn {k, lenses} ->
      Enum.with_index(lenses)
      |> Enum.map(fn {{strength, _label}, idx} ->
        (k + 1) * (idx + 1) * String.to_integer(strength)
      end)
      |> Enum.sum()
    end)
    |> Enum.sum()
  end
end

# Part 1
_output = File.read!("input")
  |> String.split(",", trim: true)
  |> Enum.map(&String.to_charlist/1)
  |> Enum.map(&Util.hash/1)
  |> Enum.sum()

# Part 2
hashmap = File.read!("input")
  |> String.split(",", trim: true)
  |> Enum.reduce(%{}, fn instruction, acc -> Util.hashmap(instruction, acc) end)
output = Util.calculate_power(hashmap)

IO.inspect(output)
