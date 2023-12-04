
defmodule Util do
    def getDigits(input) do
        String.graphemes(input)
        |> Enum.filter(fn x -> x in ["1","2","3","4","5","6","7","8","9","0"] end)
    end

    def wordsToDigits(input) do
        digitLookup = %{
            "one" => "o1e",
            "two" => "t2o",
            "three" => "t3e",
            "four" => "f4r",
            "five" => "f5e",
            "six" => "s6x",
            "seven" => "s7n",
            "eight" => "e8t",
            "nine" => "n9e",
            "zero" => "z0o",
        }

        ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "zero"]
          |> Enum.reduce(input, fn x, acc -> String.replace(acc, x, fn y -> digitLookup[y] end) end)

    end
end

stream = File.stream!("day1_input1")

calibrationValues = stream 
  |> Enum.map(&String.trim/1)
  |> Enum.map(&Util.wordsToDigits/1)
  |> Enum.map(&Util.getDigits/1)
  |> Enum.map(fn x -> hd(x) <> hd(Enum.reverse(x)) end) #grab first and last values

output = calibrationValues 
  |> Enum.map(fn x -> Integer.parse(x) |> elem(0) end)
  |> Enum.reduce(0, fn i, j -> j + i end)

IO.puts(output);

File.write("day1_output1", calibrationValues |> Enum.join("\n"))


