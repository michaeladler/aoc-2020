#!/usr/bin/env bats

setup() {
  make
}

@test "part 1" {
  run ./day18_part1
  [ "$output" = "Part 1: 6923486965641" ]
}

@test "part 2" {
  run ./day18_part2
  [ "$output" = "Part 2: 70722650566361" ]
}
