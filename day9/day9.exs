defmodule Util do

  def recurseSubSequence(acc, []) do
    acc
  end
  def recurseSubSequence(acc, vals) do
    [head|rest] = vals
    cond do
      rest == [] -> acc
      true ->
        newAcc = acc ++ [hd(rest) - head]
        recurseSubSequence(newAcc, rest)
    end
  end

  def sequenceZero(seq) do
    Enum.all?(seq, fn x -> x == 0 end)
  end

end

defmodule Part1 do

  def solveLine(inputString) do
    sequence = inputString
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)
    subSeq = createSubsequence(sequence)

    # add tails together and get final val
    hd(Enum.reverse(sequence)) + hd(Enum.reverse(subSeq))
  end

  defp createSubsequence(ogSeq) do
    seq = Util.recurseSubSequence([], ogSeq)
    cond do
      Util.sequenceZero(seq) ->
        [0]
      true ->
        sub = createSubsequence(seq)
        # use tail of sub to add to prior list and bubble back up
        newVal = hd(Enum.reverse(seq)) + hd(Enum.reverse(sub))
        seq ++ [newVal]
    end
  end

end

defmodule Part2 do

  def solveLine(inputString) do
    sequence = inputString
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)
    subSeq = createSubsequence(sequence)

    # Output final value
    hd(sequence) - hd(subSeq)
  end

  defp createSubsequence(ogSeq) do
    seq = Util.recurseSubSequence([], ogSeq)
    cond do
      Util.sequenceZero(seq) ->
        [0]
      true ->
        sub = createSubsequence(seq)
        # use head of parent seq to subtract front of sub-list and bubble back up
        newVal = hd(seq) - hd(sub)
        [newVal] ++ seq
    end
  end

end


output = File.read!("input")
|> String.split("\n", trim: true)
|> Enum.map(&Part2.solveLine/1) #change to Part1 module for... you get it
|> Enum.sum()

IO.inspect(output)
