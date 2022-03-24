package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"regexp"
)

var (
	reNumber = regexp.MustCompile(`\d+`)
)

func main() {
	answer := Part1()
	fmt.Printf("Part 1: %d\n", answer)
}

func Part1() int {
	file, err := os.Open("input.txt")
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)

	return solvePart1(scanner)
}

func solvePart1(scanner *bufio.Scanner) int {
	count := 0
	for scanner.Scan() {
		line := scanner.Text()
		result, _ := ParseLine(line)
		if result {
			// log.Println("Accepted: ", line)
			count = count + 1
		}
	}
	return count
}
