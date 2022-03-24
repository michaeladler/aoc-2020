#!/usr/bin/env luajit

-- Copyright 2020, Michael Adler <therisen06@gmail.com>
local log = require("log")
log.level = "error"

local handheld = require("handheld")

local fname = "input.txt"
-- local fname = "small.txt"

local function read_input()
	local f = assert(io.open(fname, "r"))
	local program = handheld.parse(f)
	f:close()
	return program
end

local function run_until_loop(program)
	-- return true if loop was found
	local lines_visited = {}
	for i = 1, #program.instructions do
		lines_visited[i] = false
	end
	while not program:is_terminated() do
		lines_visited[program.ip] = true
		program:step()
		if lines_visited[program.ip] == true then
			log.debug("visited before! ip: ", program.ip)
			return true
		end
	end
	return false
end

local function part1()
	local program = read_input()
	run_until_loop(program)
	return program.accumulator
end

local function part2()
	local program = read_input()
	local jmp_ops = {}
	for i, instruction in pairs(program.instructions) do
		if instruction.operation == "jmp" then
			jmp_ops[i] = true
		end
	end

	for i, _ in pairs(jmp_ops) do
		local cloned_program = program:clone()
		log.info("NOPing instruction number ", i)
		cloned_program.instructions[i].operation = "nop"
		local has_loop = run_until_loop(cloned_program)
		if not has_loop then
			log.info("Program termianted!")
			return cloned_program.accumulator
		end
	end
end

local answer1 = part1()
print("Part 1:", answer1)
local answer2 = part2()
print("Part 2:", answer2)

assert(answer1 == 2003)
assert(answer2 == 1984)
