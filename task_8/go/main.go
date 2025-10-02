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
