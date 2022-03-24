#!/usr/bin/env luajit

-- Copyright 2020, Michael Adler <therisen06@gmail.com>
local log = require("log")
log.level = "error"

local matrix = require("aoc.matrix")
local rotate, flip = matrix.rotate, matrix.flip

local fname = "input.txt"
-- local fname = "small.txt"

local function read_input()
	local tiles = {}

	local tile_no = nil
	local current = nil
	local count = 0
	local f = io.open(fname, "r")
	for line in f:lines() do
		local m = line:match("^Tile%s+(%d+)")
		if m then
			if current then
				tiles[tile_no] = current
				count = count + 1
			end
			tile_no = tonumber(m)
			current = nil
		else
			current = current or {}
			local row = {}
			for c in line:gmatch("[%.#]") do
				table.insert(row, c)
			end
			if #row > 0 then
				table.insert(current, row)
			end
		end
	end
	f:close()
	if current then
		tiles[tile_no] = current
		count = count + 1
	end
	return count, tiles
end

--- Permutate generates all possible orientations (rotate, flip).
-- In total, 4 (rotations) * 2 (flips) = 8 permutations are generated.
local function permutate(mat)
	return coroutine.wrap(function()
		for i = 1, 2 do
			coroutine.yield(mat)
			for _ = 1, 3 do
				rotate(mat)
				coroutine.yield(mat)
			end
			if i == 1 then
				flip(mat)
			end
		end
	end)
end

local function get_col(mat, j)
	local b = {}
	for i = 1, #mat do
		table.insert(b, mat[i][j])
	end
	return table.concat(b)
end

local function west_border(mat)
	return get_col(mat, 1)
end

local function east_border(mat)
	return get_col(mat, #mat[1])
end

local function north_border(mat)
	return table.concat(mat[1])
end

local function south_border(mat)
	return table.concat(mat[#mat])
end

--- Generate all possible north borders.
local function build_north_borders(tiles)
	local top_borders = {}
	for tile_no, mat in pairs(tiles) do
		for m in permutate(mat) do
			local s = north_border(m)
			top_borders[s] = top_borders[s] or {}
			table.insert(top_borders[s], tile_no)
		end
	end
	return top_borders
end

local function copy_mat(t)
	local result = {}
	for i = 1, #t do
		for j = 1, #t[i] do
			result[i] = result[i] or {}
			result[i][j] = t[i][j]
		end
	end
	return result
end

local function find_corners(tiles, north_borders)
	-- Tiles at the edge of the image also have this border, but the outermost
	-- edges won't line up with any other tiles.
	local candidates = {}
	for brd, tile_numbers in pairs(north_borders) do
		if #tile_numbers == 1 then
			local tile_no = tile_numbers[1]
			candidates[tile_no] = candidates[tile_no] or {}
			table.insert(candidates[tile_no], brd)
		end
	end

	local final_candidates = {}
	for tile_no, borders in pairs(candidates) do
		for _, b in ipairs(borders) do
			local mat = tiles[tile_no]
			for m in permutate(mat) do
				if table.concat(m[1]) == b then
					local brd = west_border(m)
					if #north_borders[brd] == 1 then
						log.debug(
							"Candidate for top left: tile_no=",
							tile_no,
							" north_border: ",
							b,
							", west_border: ",
							brd
						)
						final_candidates[tile_no] = copy_mat(m)
						-- there may be more than one, but let's hope it's enough to look at the first one
						goto continue
					end
				end
			end
		end
		::continue::
	end

	return final_candidates
end

local function find_neighbor(north_borders, tile_no, border)
	for _, other_tile_no in ipairs(north_borders[border]) do
		if other_tile_no ~= tile_no then
			return other_tile_no
		end
	end
end

local function fill_row(width, north_borders, tiles, grid, grid_numbers, row)
	for i = 2, width do
		local east = east_border(grid[row][i - 1])
		local neighbor_number = find_neighbor(north_borders, grid_numbers[row][i - 1], east)
		grid_numbers[row][i] = neighbor_number
		for mat in permutate(tiles[neighbor_number]) do
			if west_border(mat) == east then
				grid[row][i] = mat
				break
			end
		end
	end
end

local function solve_puzzle(tiles, width)
	local north_borders = build_north_borders(tiles)
	local corners = find_corners(tiles, north_borders)

	local grid = {}
	local grid_numbers = {}
	for i = 1, width do
		for j = 1, width do
			grid[i] = grid[i] or {}
			grid[i][j] = {}
			grid_numbers[i] = grid_numbers[i] or {}
			grid_numbers[i][j] = {}
		end
	end
	for k, v in pairs(corners) do
		grid_numbers[1][1] = k
		grid[1][1] = v
		break
	end

	for row = 1, width do
		fill_row(width, north_borders, tiles, grid, grid_numbers, row)

		if row + 1 <= width then
			-- go to the next row, find first tile in this row
			local south = south_border(grid[row][1])
			local tile_no = find_neighbor(north_borders, grid_numbers[row][1], south)
			for mat in permutate(tiles[tile_no]) do
				if north_border(mat) == south then
					grid[row + 1][1] = mat
					grid_numbers[row + 1][1] = tile_no
					break
				end
			end
		end
	end

	return grid, grid_numbers
end

local function remove_borders(grid)
	local n = #grid
	for i = 1, n do
		for j = 1, n do
			local t = grid[i][j]
			-- remove top row
			table.remove(t, 1)
			-- remove bottom row
			table.remove(t, #t)
			-- remove first and last column
			for row = 1, #t do
				table.remove(t[row], 1)
				table.remove(t[row], #t[row])
			end
		end
	end
end

local function merge_tiles(grid)
	local result = {}
	local dim = #grid[1][1] -- dimension of a tile
	local n = #grid
	local function insert(t, row, col)
		local outer_row = (row - 1) * dim
		local outer_col = (col - 1) * dim
		for i = 1, dim do
			for j = 1, dim do
				result[outer_row + i] = result[outer_row + i] or {}
				result[outer_row + i][outer_col + j] = t[i][j]
			end
		end
	end

	for i = 1, n do
		for j = 1, n do
			insert(grid[i][j], i, j)
		end
	end
	return result
end

--[[
                  #
#    ##    ##    ###
 #  #  #  #  #  #
--]]
local seamonster_coords = {
	{ 0, 0 },
	{ 1, 1 },
	{ 1, 4 },
	{ 0, 5 },
	{ 0, 6 },
	{ 1, 7 },
	{ 1, 10 },
	{ 0, 11 },
	{ 0, 12 },
	{ 1, 13 },
	{ 1, 16 },
	{ 0, 17 },
	{ 0, 18 },
	{ -1, 18 },
	{ 0, 19 },
}
local function is_seamonster(grid, x, y)
	for _, coords in ipairs(seamonster_coords) do
		local delta_x, delta_y = coords[1], coords[2]
		if (grid[x + delta_x] or {})[y + delta_y] ~= "#" then
			return false
		end
	end
	return true
end

local function count_seamonsters(grid)
	local n = #grid
	local count = 0
	for i = 1, n do
		for j = 1, n do
			if is_seamonster(grid, i, j) then
				count = count + 1
			end
		end
	end
	return count
end

local function part1()
	local _, tiles = read_input()
	local north_borders = build_north_borders(tiles)
	local corners = find_corners(tiles, north_borders)

	local total = 1
	for k, _ in pairs(corners) do
		total = total * k
	end
	return total
end

local function part2()
	local count, tiles = read_input()
	local width = math.sqrt(count)
	local grid, _ = solve_puzzle(tiles, width)
	remove_borders(grid)
	grid = merge_tiles(grid)
	local max_count = -math.huge
	for m in permutate(grid) do
		local c = count_seamonsters(m)
		if c > max_count then
			max_count = c
		end
	end

	local hash_count = 0
	local n = #grid
	for i = 1, n do
		for j = 1, n do
			if grid[i][j] == "#" then
				hash_count = hash_count + 1
			end
		end
	end
	local monster_size = #seamonster_coords
	local roughness = hash_count - max_count * monster_size
	return roughness
end

local answer1 = part1()
print("Part 1:", answer1)
local answer2 = part2()
print("Part 2:", answer2)

assert(answer1 == 7901522557967)
assert(answer2 == 2476)
