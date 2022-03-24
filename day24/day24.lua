-- Copyright 2020, Michael Adler <therisen06@gmail.com>
local log = require("log")
local List = require("pl.List")
local Map = require("pl.Map")
local Set = require("pl.Set")

local M = {}

local function parse_line(line)
	local directions = List({})
	local i = 1
	local n = #line
	while i <= n do
		local x = line:sub(i, i + 1)
		if x == "se" or x == "sw" or x == "nw" or x == "ne" then
			directions:append(x)
			i = i + 2
		else
			x = line:sub(i, i)
			directions:append(x)
			i = i + 1
		end
	end
	assert(i == n + 1)
	return directions
end
M.parse_line = parse_line

local function read_input(fname)
	local f = io.open(fname, "r")
	local directions = List({})
	for line in f:lines() do
		directions:append(parse_line(line))
	end
	f:close()
	return directions
end
M.read_input = read_input

local function calc_coords(directions)
	-- “odd-r” horizontal layout shoves odd rows right
	-- see https://www.redblobgames.com/grids/hexagons/
	local x, y = 0, 0 -- reference tile
	log.debug("Processing:", directions)
	for c in directions:iter() do
		if c == "e" then
			log.debug("going east")
			x = x + 1
		elseif c == "w" then
			log.debug("going west")
			x = x - 1
		elseif c == "se" then
			log.debug("going south-east")
			if y % 2 == 1 then
				x = x + 1
			end
			y = y + 1
		elseif c == "sw" then
			log.debug("going south-west")
			if y % 2 == 0 then
				x = x - 1
			end
			y = y + 1
		elseif c == "nw" then
			log.debug("going north-west")
			if y % 2 == 0 then
				x = x - 1
			end
			y = y - 1
		elseif c == "ne" then
			log.debug("going north-east")
			if y % 2 == 1 then
				x = x + 1
			end
			y = y - 1
		else
			log.error("Missing case:", c)
			assert(false, c)
		end
		log.debug("x:", x, "y:", y)
	end
	return x, y
end
M.calc_coords = calc_coords

local function count_black_tiles(colors)
	local result = 0
	for _, v in colors:iter() do
		if v == true then
			result = result + 1
		end
	end
	return result
end

local function hash_point(x, y)
	return string.format("%d\0%d", x, y)
end

local _cache = {}
local function unhash_point(s)
	local val = _cache[s]
	if not val then
		local x, y = s:match("(%-?%d+)%z(%-?%d+)")
		val = { tonumber(x), tonumber(y) }
		_cache[s] = val
	end
	return val[1], val[2]
end

local function build_map(input)
	local colors = Map({}) -- black: true, nil or false: white
	for directions in input:iter() do
		local x, y = calc_coords(directions)
		local key = hash_point(x, y)
		colors[key] = not colors[key]
	end
	return colors
end

local function part1(fname)
	local input = read_input(fname)
	local colors = build_map(input)
	return count_black_tiles(colors)
end
M.part1 = part1

local function neighbors(x, y)
	return coroutine.wrap(function()
		-- e
		coroutine.yield(x + 1, y)
		-- w
		coroutine.yield(x - 1, y)
		-- se
		local my_x = x
		if y % 2 == 1 then
			my_x = my_x + 1
		end
		coroutine.yield(my_x, y + 1)
		-- sw
		my_x = x
		if y % 2 == 0 then
			my_x = my_x - 1
		end
		coroutine.yield(my_x, y + 1)
		-- nw
		my_x = x
		if y % 2 == 0 then
			my_x = my_x - 1
		end
		coroutine.yield(my_x, y - 1)
		-- ne
		my_x = x
		if y % 2 == 1 then
			my_x = my_x + 1
		end
		coroutine.yield(my_x, y - 1)
	end)
end
M.neighbors = neighbors

local function part2(fname)
	local steps = 100

	local input = read_input(fname)
	local colors = build_map(input)

	for _ = 1, steps do
		local changes = Map({})
		local white_candidates = Set({})
		for k, is_black in colors:iter() do
			local x, y = unhash_point(k)
			if is_black then
				local black_count = 0
				for nb_x, nb_y in neighbors(x, y) do
					local nb_key = hash_point(nb_x, nb_y)
					if colors[nb_key] == true then
						black_count = black_count + 1
					else
						white_candidates = white_candidates + nb_key
					end
				end
				-- Any black tile with zero or more than 2 black tiles immediately adjacent to it is flipped to white.
				if black_count == 0 or black_count > 2 then
					log.debug(
						"(",
						x,
						",",
						y,
						") is a black tile with",
						black_count,
						"black neighbors => changing to white"
					)
					changes[k] = false
				end
			end
		end

		for k in Set.values(white_candidates):iter() do
			local x, y = unhash_point(k)
			local black_count = 0
			for nb_x, nb_y in neighbors(x, y) do
				local nb_key = hash_point(nb_x, nb_y)
				if colors[nb_key] == true then
					black_count = black_count + 1
					if black_count > 2 then
						break
					end
				end
			end
			-- Any white tile with exactly 2 black tiles immediately adjacent to it is flipped to black.
			if black_count == 2 then
				log.debug("(", x, ",", y, ") is a white tile with", black_count, "black neighbors => changing to black")
				changes[k] = true
			end
		end

		-- apply changes
		for k, v in pairs(changes) do
			colors[k] = v
		end
	end
	return count_black_tiles(colors)
end
M.part2 = part2

return M
