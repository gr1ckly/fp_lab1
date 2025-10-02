defmodule Elixir23 do
  defmodule TailRecursion do
    @max_val 28123

    def count() do
      sum_2_redundant_number = redundant_numbers(1, @max_val, MapSet.new(), MapSet.new())
      ans = div(@max_val * (1 + @max_val), 2)
      count(ans, Enum.to_list(sum_2_redundant_number))
    end

    defp count(curr_ans, [head | tail]), do: count(curr_ans - head, tail)

    defp count(curr_ans, []), do: curr_ans

    def redundant_numbers(curr_number, max_val, redundant_set, sum_2redundant_set) when curr_number <= max_val do
      new_sum_delim = count_sum_delim(0, 1, curr_number)
      {new_redundant_set, new_sum_2redundant_set} = if new_sum_delim > curr_number do
          {MapSet.put(redundant_set, curr_number), MapSet.union(sum_2redundant_set, MapSet.new(new_sum_2redundant(curr_number, max_val, MapSet.to_list(MapSet.put(redundant_set, curr_number)), [])))}
        else
          {redundant_set, sum_2redundant_set}
        end
      redundant_numbers(curr_number + 1, max_val, new_redundant_set, new_sum_2redundant_set)
    end

    def redundant_numbers(curr_number, max_val, _, sum_2redundant_set) when curr_number > max_val, do: sum_2redundant_set

    def new_sum_2redundant(curr_number, max_val, [head | tail], new_list) when curr_number + head <= max_val do
      new_sum_2redundant(curr_number, max_val, tail, [head + curr_number | new_list])
    end

    def new_sum_2redundant(curr_number, max_val, [head | tail], new_list) when curr_number + head > max_val do
      new_sum_2redundant(curr_number, max_val, tail, new_list)
    end

    def new_sum_2redundant(_, _, [], new_list), do: new_list

    def count_sum_delim(curr_sum, curr_number, init_number) when curr_number <= div(init_number, 2) do
      new_sum =
        if rem(init_number, curr_number) == 0 do
          curr_sum + curr_number
        else
          curr_sum
        end

      count_sum_delim(new_sum, curr_number + 1, init_number)
    end

    def count_sum_delim(curr_sum, curr_number, init_number) when curr_number > div(init_number, 2), do: curr_sum
  end


  defmodule Recursion do
    @max_val 28123

    def count() do
      sum_2_redundant_number = redundant_numbers(1, MapSet.new())
      ans = div(@max_val * (1 + @max_val), 2)
      ans - sum_list(Enum.to_list(sum_2_redundant_number))
    end

    defp sum_list([head | tail]), do: head + sum_list(tail)

    defp sum_list([]), do: 0

    defp redundant_numbers(curr_number, redundant_set) when curr_number <= @max_val do
      new_sum_delim = count_sum_delim(1, curr_number)
      {new_set, new_sum_2redundant_list} = if new_sum_delim > curr_number do
        {MapSet.put(redundant_set, curr_number), new_sum_2redundant(curr_number, [curr_number | Enum.to_list(redundant_set)])}
      else
        {redundant_set, []}
      end
      MapSet.union(MapSet.new(new_sum_2redundant_list), redundant_numbers(curr_number + 1, new_set))
    end

    defp redundant_numbers(curr_number, _) when curr_number > @max_val, do: MapSet.new([])

    defp new_sum_2redundant(curr_number, [head | tail]) when head + curr_number <= @max_val, do: [head + curr_number | new_sum_2redundant(curr_number, tail)]

    defp new_sum_2redundant(curr_number, [head | tail]) when head + curr_number > @max_val, do: new_sum_2redundant(curr_number, tail)

    defp new_sum_2redundant(_, []), do: []

    defp count_sum_delim(curr_number, init_number) when curr_number <= init_number / 2, do: (if rem(init_number, curr_number) == 0, do: curr_number, else: 0) + count_sum_delim(curr_number + 1, init_number)

    defp count_sum_delim(curr_number, init_number) when curr_number > init_number / 2, do: 0

  end

  defmodule ModuleRealization do
    alias Elixir23.TailRecursion, as: TR
    @max_val 28123

    def count() do
      sum_2redundant_set = TR.redundant_numbers(1, @max_val, MapSet.new([]), MapSet.new([]))
      generate_numbers(@max_val)
      |> filter_not_sum_2redundant(sum_2redundant_set)
      |> sum_not_2redundant()
    end

    defp generate_numbers(n), do: 1..n

    defp filter_not_sum_2redundant(list, sum_2redundant_set), do: Enum.filter(list, fn x -> !MapSet.member?(sum_2redundant_set, x) end)

    defp sum_not_2redundant(list), do: Enum.sum(list)

  end

  defmodule MapRealization do
    alias Elixir23.TailRecursion, as: TR
    @max_val 28123

    def count() do
      {_, sum_2redundant_set} = 1..@max_val
      |> Enum.map(fn x -> {x, TR.count_sum_delim(0, 1, x)} end)
      |> Enum.map(fn {x, sum_delim} -> if sum_delim > x, do: x, else: 0 end)
      |> Enum.reduce({[], MapSet.new([])}, fn x, {list_acc, set_acc} -> if x != 0, do: {[x | list_acc], MapSet.union(set_acc, MapSet.new(TR.new_sum_2redundant(x, @max_val, [x | list_acc], [])))}, else: {list_acc, set_acc} end)
      sum_2redundant_set
      |> Enum.reduce(div(@max_val * (1 + @max_val), 2), fn x, acc -> acc - x end)
    end
  end

  defmodule StreamRealization do
    alias Elixir23.TailRecursion, as: TR
    @max_val 28123

    def count() do
      {_, sum_2redundant_set} = Stream.unfold(1, fn x -> {x, x + 1} end)
      |> Stream.take(@max_val)
      |> Stream.filter(fn x -> x < TR.count_sum_delim(0, 1, x) end)
      |> Enum.reduce({[], MapSet.new([])}, fn x, {list_acc, set_acc} -> if x != 0, do: {[x | list_acc], MapSet.union(set_acc, MapSet.new(TR.new_sum_2redundant(x, @max_val, [x | list_acc], [])))}, else: {list_acc, set_acc} end)

      Stream.unfold(1, fn x -> {x, x + 1} end)
      |> Stream.take(@max_val)
      |> Stream.filter(fn x -> !MapSet.member?(sum_2redundant_set, x) end)
      |> Enum.sum()
    end

  end

end
