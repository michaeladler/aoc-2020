#!/usr/bin/env luajit

local log = require("log")
log.level = "error"

local Stack = require("aoc.stack")

local fname = "input.txt"
-- local fname = "small.txt"

local function build_rev_graph()
	local rev_graph = {}
	local f = io.open(fname, "r")
	for line in f:lines() do
		local color_src, dest = line:match("^([%a%s]-)%sbags contain%s(.*)%.$")
		for amount, color_dest in dest:gmatch("(%d+)%s+([%a%s]-)%s+bags?") do -- notice: the last letter in bags is optional!
			amount = tonumber(amount)
			-- create reverse graph, since we want to go from bottom (dest) to top
			local targets = rev_graph[color_dest] or {}
			table.insert(targets, { amount = amount, to = color_src })
			rev_graph[color_dest] = targets
		end
	end
	f:close()
	return rev_graph
end

local function part1()
	local graph = build_rev_graph()
	local visited = {}
	local stack = Stack:Create()
	stack:push("shiny gold")
	-- dfs
	while not stack:is_empty() do
		local node = stack:pop()
		log.progress("popped from stack: ", node)

		if visited[node] == true then
			log.debug("skipping since already visited: ", node)
			goto continue
		end

		log.debug("marking as visited: ", node)
		visited[node] = true

		local neighbors = graph[node]
		if not neighbors then
			log.debug("no neighbors for node: ", node)
			goto continue
		end
		for _, nb in ipairs(neighbors) do
			log.debug("adding node to stack: ", nb.to)
			-- add neighbors to stack
			stack:push(nb.to)
		end

		::continue::
	end

	local count = -1 -- shiny gold is marked as visited too, so we start at -1
	for node, _ in pairs(visited) do
		log.info("visited node: ", node)
		count = count + 1
	end
	return count
end

local function build_graph()
	-- same as build_rev_graph, but arrows reversed
	local graph = {}
	local f = io.open(fname, "r")
	for line in f:lines() do
		local color_src, dest = line:match("^([%a%s]-)%sbags contain%s(.*)%.$")
		for amount, color_dest in dest:gmatch("(%d+)%s+([%a%s]-)%s+bags?") do
			amount = tonumber(amount)
			local targets = graph[color_src] or {}
			table.insert(targets, { amount = amount, to = color_dest })
			graph[color_src] = targets
		end
	end
	f:close()
	return graph
end

local function part2()
	local graph = build_graph()

	local function go(node)
		log.debug("go node: ", node)
		local neighbors = graph[node]
		if neighbors == nil then
			log.debug("node ", node, " has no children")
			return 1
		end

		log.progress("replacing ", node, " with its children")
		local sum = 0
		for _, n in pairs(neighbors) do
			local summand = n.amount * go(n.to)
			log.progress("adding ", summand, " to ", node)
			sum = sum + summand
		end
		return 1 + sum
	end

	local result = go("shiny gold") - 1 -- do not count shiny gold itself
	return result
end

local answer1 = part1()
print("Part 1:", answer1)
local answer2 = part2()
print("Part 2:", answer2)

assert(answer1 == 248)
assert(answer2 == 57281)
