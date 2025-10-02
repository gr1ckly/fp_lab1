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
