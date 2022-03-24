all: day01 day02 day03 day04 day05 day06 day07 day08 day09 day10 day11 day12 day13 day14 day15 day16 day17 day18 day19 day20 day21 day22 day23 day24 day25

day01 day02 day03 day06 day07 day09 day10 day11 day12 day13 day15 day16 day17 day20 day21 day22:
	@cd $@ && ./main.lua

day04 day05 day08:
	@cd $@ && busted . && ./main.lua

day23 day24:
	@cd $@ && busted .

day14:
	@cd $@ && nix-shell -p lua5_4 --run ./main.lua

day18 day25:
	@cd $@ && bats .

day19:
	@cd $@ && go test && go run . && node part2.js

.PHONY: all day01 day02 day03 day04 day05 day06 day07 day08 day09 day10 day11 day12 day13 day14 day15 day16 day17 day18 day19 day20 day21 day22 day23 day24 day25
