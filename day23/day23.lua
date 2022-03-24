-- Copyright 2020, Michael Adler <therisen06@gmail.com>
local log = require("log")
local List = require("pl.List")
local Map = require("pl.Map")
local Set = require("pl.Set")

local M = {}

local function parse_input(input)
	local cups = List({})
	for d in input:gmatch("%d") do
		cups:append(tonumber(d))
	end
	return cups
end

local function new_node(value)
	return { value = value, next = nil }
end

local function build_linked_list(cups)
	local head = new_node(cups[1])
	local pos = Map({}) -- cup label -> node
	pos[cups[1]] = head
	local old = head
	local n = #cups
	for i = 2, n do
		local val = cups[i]
		local node = new_node(val)
		pos[val] = node
		old.next = node
		old = node
	end
	-- wrap around
	old.next = head
	return head, pos
end

local function play_game(head, cups_map, min_cup_label, max_cup_label, total_rounds)
	local first = head
	local n = cups_map:len()
	log.info(
		"Playing",
		total_rounds,
		"rounds. head:",
		head.value,
		", min_cup_label:",
		min_cup_label,
		", max_cup_label:",
		max_cup_label
	)
	for round = 1, total_rounds do
		log.progress("--- move ", round, " ---")
		if log.level == "debug" then
			local s = ""
			local node = first
			for i = 1, n do
				if i == 1 then
					s = tonumber(node.value)
				else
					s = s .. ", " .. tonumber(node.value)
				end
				node = node.next
			end
			log.debug("cups:", s)
		end
		local head_value = head.value
		log.debug("head_value: ", head_value)

		-- 1. The crab picks up the three cups that are immediately clockwise of the current cup
		local pick_up = List({ head.next, head.next.next, head.next.next.next })
		log.debug("pick up:", pick_up[1].value, ",", pick_up[2].value, ",", pick_up[3].value)
		head.next = pick_up[3].next

		-- 2. The crab selects a destination cup
		local dest_label = head_value - 1
		if dest_label < min_cup_label then
			dest_label = max_cup_label
		end
		local pick_up_values = Set({
			pick_up[1].value,
			pick_up[2].value,
			pick_up[3].value,
		})
		while pick_up_values[dest_label] do
			-- the crab will keep subtracting one until it finds a cup that wasn't just picked up
			dest_label = dest_label - 1
			if dest_label < min_cup_label then
				dest_label = max_cup_label
			end
		end
		log.debug("destination: ", dest_label)

		-- 3. The crab places the cups it just picked up so that they
		-- are immediately clockwise of the destination cup.
		local dest_node = cups_map[dest_label]
		local dest_neighbor = dest_node.next
		dest_node.next = pick_up[1]
		pick_up[3].next = dest_neighbor

		-- 4. The crab selects a new current cup: the cup which is immediately clockwise of the current cup.
		head = head.next
	end
end

local function part1(input, move_count)
	local cups = parse_input(input)

	local head, cups_map = build_linked_list(cups)
	local min_cup_label, max_cup_label = cups:minmax()

	play_game(head, cups_map, min_cup_label, max_cup_label, move_count)

	-- Starting after the cup labeled 1, collect the other cups' labels clockwise
	-- into a single string with no extra characters; each number except 1 should
	-- appear exactly once
	head = cups_map[1].next
	local n = cups:len()
	local result = 0
	for _ = 1, n - 1 do
		result = result * 10 + head.value
		head = head.next
	end
	return result
end

local function part2(input)
	local cups = parse_input(input)
	local min_cup_label, actual_max = cups:minmax()
	local max_cup_label = 1000000

	local head, cups_map = build_linked_list(cups)

	-- fill up
	local last_node = cups_map[cups[#cups]]
	log.debug("last_node:", last_node.value)
	for i = actual_max + 1, max_cup_label do
		local node = new_node(i)
		cups_map[i] = node
		last_node.next = node
		last_node = node
	end
	last_node.next = head

	play_game(head, cups_map, min_cup_label, max_cup_label, 10000000)

	local my_node = cups_map[1].next
	local a, b = my_node.value, my_node.next.value
	log.debug("Factors:", a, ",", b)
	return a * b
end

M.parse_input = parse_input
M.part1 = part1
M.part2 = part2

return M
