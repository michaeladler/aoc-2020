#!/usr/bin/env luajit

local function read_input()
	-- keep track of trees only
	local trees = {}

	local f = io.open("input.txt", "r")
	local y = 1
	local x_max = 1
	for line in f:lines() do
		local n = #line
		if n > x_max then
			x_max = n
		end
		for x = 1, n do
			local c = line:sub(x, x)
			if c == "#" then
				if not trees[x] then
					trees[x] = {}
				end
				trees[x][y] = true
			end
		end
		y = y + 1
	end
	f:close()

	return x_max, y, trees
end

local function count_trees(x_max, y_max, trees, delta_x, delta_y)
	local x = 0
	local y = 1
	local count = 0
	while y <= y_max do
		local t = trees[1 + x] -- lua starts counting with 1
		if t and t[y] == true then
			count = count + 1
		end
		x = (x + delta_x) % x_max
		y = y + delta_y
	end
	return count
end

local function part1()
	local x_max, y_max, tree = read_input()
	return count_trees(x_max, y_max, tree, 3, 1)
end

local function part2()
	local x_max, y_max, tree = read_input()
	local a = count_trees(x_max, y_max, tree, 1, 1)
	local b = count_trees(x_max, y_max, tree, 3, 1)
	local c = count_trees(x_max, y_max, tree, 5, 1)
	local d = count_trees(x_max, y_max, tree, 7, 1)
	local e = count_trees(x_max, y_max, tree, 1, 2)
	return a * b * c * d * e
end

local answer1 = part1()
print("Part 1:", answer1)
local answer2 = part2()
print("Part 2:", answer2)

assert(answer1 == 218, "answer1")
assert(answer2 == 3847183340, "answer2")
