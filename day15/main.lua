#!/usr/bin/env luajit

-- Copyright 2020, Michael Adler <therisen06@gmail.com>
local log = require("log")
log.level = "error"

local input = { 1, 0, 15, 2, 10, 13 }
local max_rounds = 2020

local function part1()
	local hist = { [0] = {} }
	local turn = 1
	local n = #input
	local last_number = nil
	while turn <= max_rounds do
		local new_num
		if turn <= n then
			new_num = input[turn]
		else
			local localhist = hist[last_number]
			if localhist == nil or #localhist <= 1 then
				log.debug("last_number is new")
				new_num = 0
			else
				log.debug("number has been spoken before")
				local count = #localhist
				new_num = localhist[count] - localhist[count - 1]
			end
		end
		log.progress("Turn ", turn, ": ", new_num)
		if not hist[new_num] then
			hist[new_num] = {}
		end
		table.insert(hist[new_num], turn)
		last_number = new_num
		turn = turn + 1
	end
	return last_number
end

local function part2()
	-- LuaJIT is so fast, we don't need to optimize anything here :)
	max_rounds = 30000000
	return part1()
end

local answer1 = part1()
print("Part 1:", answer1)
local answer2 = part2()
print("Part 2:", answer2)

assert(answer1 == 211)
assert(answer2 == 2159626)
