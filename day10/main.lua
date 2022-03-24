#!/usr/bin/env luajit

-- Copyright 2020, Michael Adler <therisen06@gmail.com>
local log = require("log")
log.level = "error"

local List = require("pl.List")

local fname = "input.txt"
-- local fname = "small.txt"
-- local fname = "second.txt"

local function read_input()
	local numbers = List()
	local f = io.open(fname, "r")
	for line in f:lines() do
		numbers:append(tonumber(line))
	end
	f:close()
	return numbers
end

local function part1()
	local list = read_input()
	local numbers = {}
	for num in list:iter() do
		numbers[num] = true
	end
	local _, max_num = list:minmax()
	local max_jolt = max_num + 3
	numbers[max_jolt] = true

	local diffs = { 0, 0, 0 }
	local current_jolt = 0
	while current_jolt < max_jolt do
		for delta = 1, 3 do
			local candidate = current_jolt + delta
			if numbers[candidate] then
				log.progress("Connecting current_jolt ", current_jolt, " with jolt ", candidate, " => delta: ", delta)
				current_jolt = candidate
				diffs[delta] = diffs[delta] + 1
				break
			end
		end
	end
	log.info("diffs: ", diffs[1], ", ", diffs[2], ", ", diffs[3])
	return diffs[1] * diffs[3]
end

local function compute_deltas(numbers)
	-- numbers is a **sorted** List
	local deltas = List()
	local n = numbers:len()
	for i = 1, n - 1 do
		deltas:append(numbers[i + 1] - numbers[i])
	end
	return deltas
end

local _facs = {}
local function fac(n)
	local result = _facs[n]
	if result then
		return result
	end
	result = 1
	for i = 2, n do
		result = result * i
	end
	_facs[n] = result
	return result
end

local function my_slice(deltas, start)
	-- adjust start index
	local adjusted_start = start
	local n = #deltas
	if start > n then
		log.debug("No slice left")
		return nil, nil
	end
	if deltas[start] == 3 then
		for i = start + 1, n do
			if deltas[i] ~= 3 then
				adjusted_start = i
				break
			end
		end
	end
	log.debug("start: ", start, " adjusted_start: ", adjusted_start)

	for i = adjusted_start + 1, n do
		if deltas[i] == 3 then
			return adjusted_start, i - 1
		end
	end
	log.debug("No slice left")
	return nil, nil
end

local function part2()
	local numbers = read_input()
	numbers:append(0)
	local _, max = numbers:minmax()
	numbers:append(max + 3)
	numbers:sort()
	local deltas = compute_deltas(numbers)

	log.debug("deltas: ", tostring(deltas))
	local total = 1
	local slice_start, slice_end = my_slice(deltas, 1)
	while slice_start and slice_end do
		-- 1) Take numbers until we find the number '3'
		local sublist = deltas:slice(slice_start, slice_end)
		log.info("slice_start: ", slice_start, ", slice_end: ", slice_end, " sublist: ", tostring(sublist))
		local s = 0
		for val in sublist:iter() do
			s = s + val
		end
		local combinations = 0
		for k1 = 0, s do
			for k2 = 0, math.ceil(s / 2) do
				for k3 = 0, math.ceil(s / 3) do
					if k1 + k2 * 2 + k3 * 3 == s then
						local coeff = fac(k1 + k2 + k3) / (fac(k1) * fac(k2) * fac(k3))
						log.progress("s=", s, ", found coefficients: ", k1, ", ", k2, ", ", k3, " => ", coeff, " coeff")
						combinations = combinations + coeff
					end
				end
			end
		end
		log.progress("Multiplying with combinations: ", combinations)
		total = total * combinations

		slice_start, slice_end = my_slice(deltas, slice_end + 1)
	end

	return total
end

local answer1 = part1()
print("Part 1:", answer1)
local answer2 = part2()
print("Part 2:", answer2)

assert(answer1 == 2310)
assert(answer2 == 64793042714624)
