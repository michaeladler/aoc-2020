#!/usr/bin/env luajit

local f = io.open("input.txt")
local numbers = {}
for line in f:lines() do
	table.insert(numbers, tonumber(line))
end
f:close()

local function part1()
	for i = 1, #numbers, 1 do
		for j = 1, #numbers, 1 do
			local x = numbers[i]
			local y = numbers[j]
			if x + y == 2020 then
				return x * y
			end
		end
	end
end

local function part2()
	for i = 1, #numbers, 1 do
		for j = 1, #numbers, 1 do
			for k = 1, #numbers, 1 do
				local x = numbers[i]
				local y = numbers[j]
				local z = numbers[k]
				if x + y + z == 2020 then
					return x * y * z
				end
			end
		end
	end
end

local answer1 = part1()
print("Part 1:", answer1)
local answer2 = part2()
print("Part 2:", answer2)

assert(answer1 == 485739, "answer1")
assert(answer2 == 161109702, "answer2")
