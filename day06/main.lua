#!/usr/bin/env luajit

local Map = require("pl.Map")

local function read_input()
	local result = {}
	local f = io.open("input.txt", "r")
	local current_group = nil
	local group_count = 0
	for line in f:lines() do
		if line == "" then
			table.insert(result, { count = group_count, group = current_group })
			current_group = nil
			group_count = 0
			goto continue
		end

		group_count = group_count + 1
		current_group = current_group or Map({})
		for c in line:gmatch("%a") do
			local old = current_group:get(c) or 0
			current_group:set(c, old + 1)
		end

		::continue::
	end
	f:close()
	-- do not forget last group
	if current_group then
		table.insert(result, { count = group_count, group = current_group })
	end
	return result
end

local groups = read_input()

local function part1()
	local count = 0
	for _, t in ipairs(groups) do
		count = count + t.group:len()
	end
	return count
end

local function part2()
	local count = 0
	for _, t in ipairs(groups) do
		local group_count = t.count
		local values = t.group:values()
		for v in values:iter() do
			if v == group_count then
				count = count + 1
			end
		end
	end
	return count
end

local answer1 = part1()
print("Part 1:", answer1)
assert(answer1 == 6551)
local answer2 = part2()
print("Part 2:", answer2)
assert(answer2 == 3358)
