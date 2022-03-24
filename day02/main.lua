#!/usr/bin/env luajit

require("io")
require("bit")

local function is_valid(min, max, letter, pw)
	local matches = 0
	for i = 1, #pw do
		local c = pw:sub(i, i)
		if c == letter then
			matches = matches + 1
		end
	end
	return tonumber(min) <= matches and matches <= tonumber(max)
end

local bxor = bit.bxor
local function is_valid2(min, max, letter, pw)
	local found_min = 0
	if pw:sub(min, min) == letter then
		found_min = 1
	end

	local found_max = 0
	if pw:sub(max, max) == letter then
		found_max = 1
	end

	return bxor(found_min, found_max) == 1
end

local f = io.open("input.txt", "r")
local valid_counts = 0
local valid_counts2 = 0
for line in f:lines() do
	local min, max, letter, pw = string.match(line, "([%d]*).([%d]*)[%s*]([%a]*):[%s]*([%a]*)")
	if is_valid(min, max, letter, pw) then
		valid_counts = valid_counts + 1
	end
	if is_valid2(min, max, letter, pw) then
		valid_counts2 = valid_counts2 + 1
	end
end
f:close()

print("Part 1", valid_counts)
print("Part 2:", valid_counts2)

assert(valid_counts == 582, "part1")
assert(valid_counts2 == 729, "part2")
