#!/usr/bin/env bats

setup() {
  make
}

@test "part 1" {
  run ./day25
  [ "$output" = "Part 1: 6198540" ]
}
