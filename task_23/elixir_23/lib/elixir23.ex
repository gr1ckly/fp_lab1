defmodule Elixir23 do
  @moduledoc """
  Модуль, содержащий разные реализации решения задачи №23 от "Euler project".
  """

  defmodule TailRecursion do
    @moduledoc """
    Реализация с хвостовой рекурсией.
    """

    @max_val 28_123

    def count do
      redundant_sums =
        redundant_numbers(1, @max_val, MapSet.new(), MapSet.new())

      total_sum = div(@max_val * (1 + @max_val), 2)
      subtract_all(total_sum, Enum.to_list(redundant_sums))
    end

    defp subtract_all(curr_sum, [head | tail]),
      do: subtract_all(curr_sum - head, tail)

    defp subtract_all(curr_sum, []), do: curr_sum

    def redundant_numbers(curr, max, redundant_set, sums) when curr <= max do
      sum_divisors = count_sum_divisors(0, 1, curr)

      {new_redundant, new_sums} =
        if sum_divisors > curr do
          updated = MapSet.put(redundant_set, curr)

          {updated,
           MapSet.union(
             sums,
             MapSet.new(new_sum_redundant(curr, max, MapSet.to_list(updated), []))
           )}
        else
          {redundant_set, sums}
        end

      redundant_numbers(curr + 1, max, new_redundant, new_sums)
    end

    def redundant_numbers(curr, max, _, sums) when curr > max, do: sums

    def new_sum_redundant(curr, max, [head | tail], acc) when curr + head <= max,
      do: new_sum_redundant(curr, max, tail, [head + curr | acc])

    def new_sum_redundant(curr, max, [head | tail], acc) when curr + head > max,
      do: new_sum_redundant(curr, max, tail, acc)

    def new_sum_redundant(_, _, [], acc), do: acc

    def count_sum_divisors(sum, divisor, n) when divisor <= div(n, 2) do
      new_sum =
        if rem(n, divisor) == 0 do
          sum + divisor
        else
          sum
        end

      count_sum_divisors(new_sum, divisor + 1, n)
    end

    def count_sum_divisors(sum, divisor, n) when divisor > div(n, 2), do: sum
  end

  defmodule Recursion do
    @moduledoc """
    Рекурсивная реализация.
    """

    @max_val 28_123

    def count do
      redundant_sums = redundant_numbers(1, MapSet.new())
      total_sum = div(@max_val * (1 + @max_val), 2)
      total_sum - Enum.sum(redundant_sums)
    end

    defp redundant_numbers(curr, set) when curr <= @max_val do
      sum_divisors = count_sum_divisors(1, curr)

      {new_set, new_sums} =
        if sum_divisors > curr do
          updated = MapSet.put(set, curr)
          {updated, new_sum_redundant(curr, [curr | Enum.to_list(set)])}
        else
          {set, []}
        end

      MapSet.union(MapSet.new(new_sums), redundant_numbers(curr + 1, new_set))
    end

    defp redundant_numbers(curr, _) when curr > @max_val, do: MapSet.new()

    defp new_sum_redundant(curr, [head | tail]) when head + curr <= @max_val,
      do: [head + curr | new_sum_redundant(curr, tail)]

    defp new_sum_redundant(curr, [head | tail]) when head + curr > @max_val,
      do: new_sum_redundant(curr, tail)

    defp new_sum_redundant(_, []), do: []

    defp count_sum_divisors(divisor, n) when divisor <= n / 2 do
      value = if rem(n, divisor) == 0, do: divisor, else: 0
      value + count_sum_divisors(divisor + 1, n)
    end

    defp count_sum_divisors(divisor, n) when divisor > n / 2, do: 0
  end

  defmodule ModuleRealization do
    @moduledoc """
    Модульная реализация.
    """

    @max_val 28_123
    alias Elixir23.TailRecursion, as: TR

    def count do
      redundant_sums = TR.redundant_numbers(1, @max_val, MapSet.new(), MapSet.new())

      1..@max_val
      |> Enum.reject(&MapSet.member?(redundant_sums, &1))
      |> Enum.sum()
    end
  end

  defmodule MapRealization do
    @moduledoc """
    Реализация с использованием Enum.map.
    """

    @max_val 28_123
    alias Elixir23.TailRecursion, as: TR

    def count do
      {_, redundant_sums} =
        1..@max_val
        |> Enum.map(&{&1, TR.count_sum_divisors(0, 1, &1)})
        |> Enum.map(fn {x, sum} -> if sum > x, do: x, else: 0 end)
        |> Enum.reject(&(&1 == 0))
        |> Enum.reduce({[], MapSet.new()}, fn x, {list_acc, set_acc} ->
          updated = MapSet.new(TR.new_sum_redundant(x, @max_val, [x | list_acc], []))
          {[x | list_acc], MapSet.union(set_acc, updated)}
        end)

      div(@max_val * (1 + @max_val), 2)
      |> Kernel.-(Enum.sum(redundant_sums))
    end
  end

  defmodule StreamRealization do
    @moduledoc """
    Реализация с использованием Stream.
    """

    @max_val 28_123
    alias Elixir23.TailRecursion, as: TR

    def count do
      {_, redundant_sums} =
        numbers_stream()
        |> Stream.filter(&(&1 < TR.count_sum_divisors(0, 1, &1)))
        |> Enum.reduce({[], MapSet.new()}, fn x, {list_acc, set_acc} ->
          updated = MapSet.new(TR.new_sum_redundant(x, @max_val, [x | list_acc], []))
          {[x | list_acc], MapSet.union(set_acc, updated)}
        end)

      numbers_stream()
      |> Stream.reject(&MapSet.member?(redundant_sums, &1))
      |> Enum.sum()
    end

    defp numbers_stream, do: Stream.iterate(1, &(&1 + 1)) |> Stream.take(@max_val)
  end
end
