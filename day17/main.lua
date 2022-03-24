#!/usr/bin/env luajit

-- Copyright 2020, Michael Adler <therisen06@gmail.com>
local log = require("log")
log.level = "error"

local Grid = require("grid")
local Grid2 = require("grid2")

local fname = "input.txt"
-- local fname = "small.txt"

local function read_input()
	local grid = Grid:new()
	local grid2 = Grid2:new()
	local f = io.open(fname, "r")
	local y = 0
	for line in f:lines() do
		local x = 0
		for c in line:gmatch("[%.#]") do
			grid:set_value(x, y, 0, c)
			grid2:set_value(x, y, 0, 0, c)
			x = x + 1
		end
		y = y + 1
	end
	f:close()
	return grid, grid2
end

local function part1()
	local grid, _ = read_input()
	for _ = 1, 6 do
		grid:cycle()
	end

	local active = 0
	for x = grid.x_min, grid.x_max do
		for y = grid.y_min, grid.y_max do
			for z = grid.z_min, grid.z_max do
				if grid:is_active(x, y, z) then
					active = active + 1
				end
			end
		end
	end
	return active
end

local function part2()
	local _, grid = read_input()
	for _ = 1, 6 do
		grid:cycle()
	end

	local active = 0
	for x = grid.x_min, grid.x_max do
		for y = grid.y_min, grid.y_max do
			for z = grid.z_min, grid.z_max do
				for w = grid.w_min, grid.w_max do
					if grid:is_active(x, y, z, w) then
						active = active + 1
					end
				end
			end
		end
	end
	return active
end

local answer1 = part1()
print("Part 1:", answer1)
local answer2 = part2()
print("Part 2:", answer2)

assert(answer1 == 301)
assert(answer2 == 2424)
