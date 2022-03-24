#!/usr/bin/env luajit
-- Copyright 2020, Michael Adler <therisen06@gmail.com>
local Ship = require("ship")
local fname = "input.txt"
-- local fname = "small.txt"

local function read_input()
	local actions = {}
	local f = io.open(fname, "r")
	for line in f:lines() do
		for action, value in line:gmatch("(%a+)(%d+)") do
			table.insert(actions, { action = action, value = tonumber(value) })
		end
	end
	f:close()
	return actions
end

local actions = read_input()
local function part1()
	local ship = Ship.new()
	for _, step in ipairs(actions) do
		ship:advance(step.action, step.value)
	end
	return ship:manhattan_dist()
end

local function part2()
	local ship = Ship.new()
	for _, step in ipairs(actions) do
		ship:advance2(step.action, step.value)
	end
	return ship:manhattan_dist()
end

local answer1 = part1()
print("Part 1:", answer1)
local answer2 = part2()
print("Part 2:", answer2)

assert(answer1 == 1441)
assert(answer2 == 61616)
