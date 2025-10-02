defmodule Elixir8 do

  defmodule TailRecursion do
    def count(n, window_size), do: count(n, window_size, 0, [])

    defp count(n, window_size, prev_mul, prev_list) when n != 0 do
      {new_mul, new_list} = count_mul(n, window_size, 1, [])
      if new_mul > prev_mul and length(new_list) == window_size do
        count(div(n, 10), window_size, new_mul, new_list)
      else
        count(div(n, 10), window_size, prev_mul, prev_list)
      end
    end

    defp count(n, _, prev_mul, prev_list) when n == 0, do: {prev_mul, prev_list}

    defp count_mul(n, window_size, curr_mul, curr_list) when n != 0 and length(curr_list) < window_size, do: count_mul(div(n, 10), window_size, curr_mul * rem(n, 10), [rem(n, 10) | curr_list])

    defp count_mul(n, window_size, curr_mul, curr_list) when n == 0 or length(curr_list) >= window_size, do: {curr_mul, curr_list}

  end

  defmodule Recursion do

    def count(n, window_size), do: count(n, window_size, 0, [])

    defp count(n, window_size, max_mul, max_list) when n > 0 do
      {curr_mul, curr_list} = loop_recursion(n, window_size, 1, [])
      new_max = max(max_mul, curr_mul)
      new_list = if curr_mul > max_mul do
        curr_list
      else
        max_list
      end
      {next_max, next_list} = count(div(n, 10), window_size, new_max, new_list)
      if next_max > new_max do
        {next_max, next_list}
      else
        {new_max, new_list}
      end
    end

    defp count(n, _, max_mul, max_list) when n == 0, do: {max_mul, max_list}

    defp loop_recursion(n, window_size, curr_mul, curr_list) when n != 0 and length(curr_list) >= window_size, do: {curr_mul, curr_list}

    defp loop_recursion(n, window_size, curr_mul, curr_list) when n != 0 and length(curr_list) < window_size, do: loop_recursion(div(n, 10), window_size, curr_mul * rem(n, 10), [rem(n, 10)| curr_list])

    defp loop_recursion(n, window_size, curr_mul, curr_list) when n == 0 do
      if length(curr_list) == window_size do
        {curr_mul, curr_list}
      else
        {0, curr_list}
      end
    end

  end

  defmodule ModuleRealization do
    def count(n, window_size) do
      generate_windows(n, window_size)
      |> count_mul
      |> max_mul
    end

    def generate_windows(n, window_size) when n > 0, do: generate_windows(n, window_size, [])

    defp generate_windows(n, window_size, curr_list) do
      if n >= 10 ** window_size do
        generate_windows(div(n, 10), window_size, [create_window(n, window_size, []) | curr_list])
      else
        curr_list
      end
    end

    defp create_window(n, window_size, curr_list) when length(curr_list) < window_size, do: create_window(div(n, 10), window_size, [rem(n, 10) | curr_list])

    defp create_window(_, window_size, curr_list) when length(curr_list) >= window_size, do: curr_list

    defp count_mul(windows_list), do: count_mul(windows_list, [])

    defp count_mul([head | tail], curr_list) do
      count_mul(tail, [{Enum.reduce(head, fn(x, acc) -> x * acc end), head} | curr_list])
    end

    defp count_mul([], curr_list), do: curr_list

    def max_mul(list), do: Enum.max_by(list, fn ({mul, _}) -> mul end)

  end

  defmodule MapRealization do
    alias Elixir8.ModuleRealization, as: MR

    def count(n, window_size) when n > 0 do
      MR.generate_windows(n, window_size)
      |> Enum.map(fn (x) -> {Enum.reduce(x, fn (y, acc) -> y * acc end), x} end)
      |> MR.max_mul
    end
  end

  defmodule StreamRealization do
    def count(n, window_size) do
      Stream.unfold(n, fn 0 -> {-1, 0}
        (n) -> {rem(n, 10), div(n, 10)}
      end)
      |> Stream.take_while(& &1 != -1)
      |> Stream.chunk_every(window_size, 1, :discard)
      |> Stream.map(fn (x) -> {Enum.reduce(x, fn(y, acc) -> y * acc end), x} end)
      |> Enum.max_by(fn ({mul, _}) -> mul end)
    end
  end

end
