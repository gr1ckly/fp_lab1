# Лабораторная работа №1
**Выполнил**: Медведев Ярослав 409111
***
## Вариант 8
The four adjacent digits in the 1000-digit number that have the greatest product are 9 * 9 * 8 * 9 = 5832.

73167176531330624919225119674426574742355349194934
96983520312774506326239578318016984801869478851843
85861560789112949495459501737958331952853208805511
12540698747158523863050715693290963295227443043557
66896648950445244523161731856403098711121722383113
62229893423380308135336276614282806444486645238749
30358907296290491560440772390713810515859307960866
70172427121883998797908792274921901699720888093776
65727333001053367881220235421809751254540594752243
52584907711670556013604839586446706324415722155397
53697817977846174064955149290862569321978468622482
83972241375657056057490261407972968652414535100474
82166370484403199890008895243450658541227588666881
16427171479924442928230863465674813919123162824586
17866458359124566529476545682848912883142607690042
24219022671055626321111109370544217506941658960408
07198403850962455444362981230987879927244284909188
84580156166097919133875499200524063689912560717606
05886116467109405077541002256983155200055935729725
71636269561882670428252483600823257530420752963450

Find the thirteen adjacent digits in the 1000-digit number that have the greatest product. What is the value of this product?
### Монолитная реализация
#### Рекурсия
```elixir
defmodule Recursion do
    @moduledoc """
    Рекурсивная реализация
    """

    def count(n, window_size), do: count(n, window_size, 0, [])

    defp count(n, window_size, max_mul, max_list) when n > 0 do
      {curr_mul, curr_list} = loop_recursion(n, window_size, 1, [])
      new_max = max(max_mul, curr_mul)
      new_list = if curr_mul > max_mul, do: curr_list, else: max_list
      {next_max, next_list} = count(div(n, 10), window_size, new_max, new_list)
      if next_max > new_max, do: {next_max, next_list}, else: {new_max, new_list}
    end

    defp count(0, _window_size, max_mul, max_list), do: {max_mul, max_list}

    defp loop_recursion(n, window_size, curr_mul, curr_list)
         when n != 0 and length(curr_list) >= window_size,
         do: {curr_mul, curr_list}

    defp loop_recursion(n, window_size, curr_mul, curr_list)
         when n != 0 and length(curr_list) < window_size,
         do:
           loop_recursion(div(n, 10), window_size, curr_mul * rem(n, 10), [rem(n, 10) | curr_list])

    defp loop_recursion(0, window_size, curr_mul, curr_list) do
      if length(curr_list) == window_size, do: {curr_mul, curr_list}, else: {0, curr_list}
    end
end
```
#### Хвостовая рекурсия
```elixir
defmodule TailRecursion do
    @moduledoc """
    Реализация с хвостовой рекурсией
    """

    def count(n, window_size), do: count(n, window_size, 0, [])

    defp count(n, window_size, prev_mul, prev_list) when n != 0 do
      {new_mul, new_list} = count_mul(n, window_size, 1, [])

      if new_mul > prev_mul and length(new_list) == window_size do
        count(div(n, 10), window_size, new_mul, new_list)
      else
        count(div(n, 10), window_size, prev_mul, prev_list)
      end
    end

    defp count(0, _window_size, prev_mul, prev_list), do: {prev_mul, prev_list}

    defp count_mul(n, window_size, curr_mul, curr_list)
         when n != 0 and length(curr_list) < window_size,
         do: count_mul(div(n, 10), window_size, curr_mul * rem(n, 10), [rem(n, 10) | curr_list])

    defp count_mul(_n, _window_size, curr_mul, curr_list), do: {curr_mul, curr_list}
end
```
### Модульная реализация
```elixir
defmodule ModuleRealization do
    @moduledoc """
    Модульная реализация
    """

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

    defp create_window(n, window_size, curr_list) when length(curr_list) < window_size,
      do: create_window(div(n, 10), window_size, [rem(n, 10) | curr_list])

    defp create_window(_n, window_size, curr_list) when length(curr_list) >= window_size,
      do: curr_list

    defp count_mul(windows_list), do: count_mul(windows_list, [])

    defp count_mul([head | tail], curr_list) do
      count_mul(tail, [{Enum.reduce(head, fn x, acc -> x * acc end), head} | curr_list])
    end

    defp count_mul([], curr_list), do: curr_list

    def max_mul(list), do: Enum.max_by(list, fn {mul, _} -> mul end)
end
```
### Генерация последовательности при помощи map
```elixir
defmodule MapRealization do
    @moduledoc """
    Реализация с использованием Enum.map
    """
    alias Elixir8.ModuleRealization, as: MR

    def count(n, window_size) when n > 0 do
      MR.generate_windows(n, window_size)
      |> Enum.map(fn x -> {Enum.reduce(x, fn y, acc -> y * acc end), x} end)
      |> MR.max_mul()
    end
end
```
### Ленивые коллекции
```elixir
defmodule StreamRealization do
    @moduledoc """
    Реализация с использованием Stream
    """

    def count(n, window_size) do
      Stream.unfold(n, fn
        0 -> {-1, 0}
        n -> {rem(n, 10), div(n, 10)}
      end)
      |> Stream.take_while(&(&1 != -1))
      |> Stream.chunk_every(window_size, 1, :discard)
      |> Stream.map(fn x -> {Enum.reduce(x, fn y, acc -> y * acc end), x} end)
      |> Enum.max_by(fn {mul, _} -> mul end)
    end
end
```
### Реализация на Golang
```go
package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

func countMaxMul(number string, window_size int) (int, []int, error) {
	digits := make([]int, 0, len(number))
	for _, char := range number {
		if char < '0' || char > '9' {
			continue
		}
		digit, _ := strconv.Atoi(string(char))
		digits = append(digits, digit)
	}

	var maxProduct int
	var maxWindow []int

	for i := 0; i <= len(digits)-window_size; i++ {
		window := digits[i : i+window_size]
		product := 1

		for _, digit := range window {
			product *= digit
		}

		if product > maxProduct {
			maxProduct = product
			maxWindow = make([]int, window_size)
			copy(maxWindow, window)
		}
	}

	return maxProduct, maxWindow, nil
}

func main() {
	reader := bufio.NewReader(os.Stdin)
	fmt.Print("Введите положительное число: ")
	number, err := reader.ReadString('\n')
	if err != nil {
		fmt.Printf("Error while input number: %v", err)
		return
	}
	number = strings.TrimSpace(number)
	fmt.Print("Введите размер окна: ")
	windowSizeStr, err := reader.ReadString('\n')
	if err != nil {
		fmt.Printf("Error while input window_size: %v", err)
		return
	}
	windowSize, err := strconv.Atoi(strings.TrimSpace(windowSizeStr))
	if err != nil {
		fmt.Printf("Error while convert window_size: %v", err)
		return
	}
	mul, dgts, err := countMaxMul(number, windowSize)
	if err != nil {
		fmt.Printf("Error counting: %v", err)
		return
	}
	fmt.Printf("Max mul: %v \n", mul)
	fmt.Printf("Digits: %v \n", dgts)
}
```
## Вариант 23
A perfect number is a number for which the sum of its proper divisors is exactly equal to the number. For example, the sum of the proper divisors of 28 would be 1 + 2 + 4 + 7 + 14 = 28, which means that 28 is a perfect number.

A number n is called deficient if the sum of its proper divisors is less than n and it is called abundant if this sum exceeds n.

As 12 is the smallest abundant number, 1 + 2 + 3 + 4 + 6 = 16, the smallest number that can be written as the sum of two abundant numbers is 24. By mathematical analysis, it can be shown that all integers greater than 28123 can be written as the sum of two abundant numbers. However, this upper limit cannot be reduced any further by analysis even though it is known that the greatest number that cannot be expressed as the sum of two abundant numbers is less than this limit.

Find the sum of all the positive integers which cannot be written as the sum of two abundant numbers.
### Монолитная реализация
#### Рекурсия
```elixir
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
```
#### Хвостовая рекурсия
```elixir
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
```
### Модульная реализация
```elixir
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
```
### Генерация последовательности при помощи map
```elixir
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
```
### Ленивые коллекции
```elixir
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
```
### Реализация на Golang
```go
package main

import "fmt"

const maxValue = 28123

func checkRedundant(number int) bool {
	if number < 1 {
		return false
	}
	sumDelim := 0
	for i := 1; i < number/2+1; i++ {
		if number%i == 0 {
			sumDelim += i
		}
	}

	return sumDelim > number
}

func main() {
	redundants := []int{}
	sum2redundants := map[int]struct{}{}
	for i := 1; i < maxValue; i++ {
		if checkRedundant(i) {
			redundants = append(redundants, i)
			for _, val := range redundants {
				if val+i <= maxValue {
					sum2redundants[val+i] = struct{}{}
				}
			}
		}
	}
	ans := maxValue * (1 + maxValue) / 2
	for k, _ := range sum2redundants {
		ans -= k
	}
	fmt.Println(ans)
}
```
***
## Вывод
В процессе выполнения лабораторной работы были достигнуты следующие результаты:

### Основные достижения:
- **Освоение основ функционального программирования** на языке Elixir
- **Практическая реализация решений** задач №8 и №23 с Project Euler

### Применённые технологии и подходы:
- **Рекурсивные методы** (обычная и хвостовая рекурсия)
- **Модульная архитектура** приложения
- **Генерация последовательностей** с использованием функции `map`
- **Ленивые вычисления** через модуль `Stream`

### Сравнительный анализ:
- Проведено **сопоставление функциональной парадигмы** (Elixir) с **императивным подходом** (Golang)
- Выявлены особенности и преимущества каждого из подходов