#!/usr/bin/env luajit

-- Copyright 2020, Michael Adler <therisen06@gmail.com>
local log = require("log")
log.level = "debug"

local nt = require("aoc.numtheory")
local chinese_remainder = nt.chinese_remainder

local fname = "input.txt"
-- local fname = "small.txt"

local function read_input()
	local f = io.open(fname, "r")
	local t = {}
	for line in f:lines() do
		table.insert(t, line)
	end
	f:close()
	local depart_time = tonumber(t[1])
	local buses = {}
	for bus_id in t[2]:gmatch("(%w+),?") do
		table.insert(buses, bus_id)
	end
	return depart_time, buses
end

local depart_time, buses = read_input()
local function part1()
	local nums = {}
	for _, bus in ipairs(buses) do
		if bus ~= "x" then
			table.insert(nums, tonumber(bus))
		end
	end
	-- search n in nums s.t. depart_time + x = 0 (mod n)
	local min = math.huge
	local bus_id = nil
	for _, n in ipairs(nums) do
		local rem = -depart_time % n
		if rem < min then
			min = rem
			bus_id = n
		end
	end
	return bus_id * min
end

local function part2()
	local a = {}
	local n = {}
	-- t = 0 mod b1
	-- t + 1 = 0 mod b2
	-- t + 2 = 0 mod b3
	for i, bus_id in ipairs(buses) do
		if bus_id == "x" then
			goto continue
		end
		local b = tonumber(bus_id)
		table.insert(n, b)
		table.insert(a, 0 - (i - 1))
		::continue::
	end
	return chinese_remainder(n, a)
end

local answer1 = part1()
print("Part 1:", answer1)
local answer2 = part2()
print(string.format("Part 2: %d", answer2))

assert(answer1 == 2947)
assert(answer2 == 526090562196173)
