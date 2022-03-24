#!/usr/bin/env luajit

-- Copyright 2020, Michael Adler <therisen06@gmail.com>
local log = require("log")
log.level = "error"

local SeatingSystem = require("seatingsystem")

local fname = "input.txt"
--local fname = "small.txt"

local function read_input()
	local grid = {}
	local f = io.open(fname, "r")
	local max_x = nil

	local y = 1
	for line in f:lines() do
		local x = 1
		for c in line:gmatch(".") do
			local t = grid[x] or {}
			t[y] = c
			grid[x] = t
			x = x + 1
		end
		if not max_x then
			max_x = #line
		end
		y = y + 1
	end
	f:close()

	return SeatingSystem.new(grid, max_x, y)
end

local function solve(seatingsystem, cb)
	repeat
		local has_changes = cb()
	until has_changes == false
	local count = 0
	for x = 1, seatingsystem.max_x do
		for y = 1, seatingsystem.max_y do
			if seatingsystem:is_occupied(x, y) then
				count = count + 1
			end
		end
	end
	return count
end

local function part1()
	local seatingsystem = read_input()
	return solve(seatingsystem, function()
		return seatingsystem:advance()
	end)
end

local function part2()
	local seatingsystem = read_input()
	return solve(seatingsystem, function()
		return seatingsystem:advance2()
	end)
end

local answer1 = part1()
print("Part 1:", answer1)
local answer2 = part2()
print("Part 2:", answer2)

assert(answer1 == 2441)
assert(answer2 == 2190)
