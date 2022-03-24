#!/usr/bin/env luajit

local fname = "input.txt"
local width = 25

-- local fname = "small.txt"
-- width = 5

local function read_input()
	local f = io.open(fname, "r")
	local numbers = {}
	for line in f:lines() do
		table.insert(numbers, tonumber(line))
	end
	f:close()
	return numbers
end

local function build_table(numbers, start, width)
	local sums = {}
	local n = #numbers
	for delta = 0, width do
		local idx = start + delta
		if idx > n then
			goto continue
		end
		local x = numbers[idx]
		for j = 1, width do
			local idy = start + j
			if idx > n then
				goto continue
			end
			local y = numbers[idy]
			if x ~= y then
				sums[x + y] = true
			end
		end
		::continue::
	end
	return sums
end

local function find_incorrect_idx(numbers)
	local sums = build_table(numbers, 1, width)
	for i = width + 1, #numbers do
		if not sums[numbers[i]] then
			return i
		end
		sums = build_table(numbers, i - width, width)
	end
	return nil
end

local function solve()
	-- Part 1
	local numbers = read_input()
	local n = find_incorrect_idx(numbers)
	local bad_num = numbers[n]
	local part1 = bad_num

	-- Part 2
	local range_start = 0
	local range_end = 0
	for i = 1, n do
		range_start = i
		local sum = numbers[i]
		for j = i + 1, n do
			range_end = j
			sum = sum + numbers[j]
			if sum == bad_num then
				goto done
			end
			if sum > bad_num then
				break
			end
		end
	end
	::done::

	local min = math.huge
	local max = -math.huge
	for i = range_start, range_end do
		local num = numbers[i]
		if num < min then
			min = num
		end
		if num > max then
			max = num
		end
	end
	local part2 = min + max
	return part1, part2
end

local part1, part2 = solve()
print("Part 1:", part1)
print("Part 2:", part2)

assert(part1 == 144381670)
assert(part2 == 20532569)
