#!/usr/bin/env luajit

-- Copyright 2020, Michael Adler <therisen06@gmail.com>
local log = require("log")
log.level = "error"

local fname = "input.txt"

local function read_input()
	local f = io.open(fname, "r")
	local rules = {}
	log.debug("parsing rules")
	local count = 0
	for line in f:lines() do
		local name, rule_str = line:match("([^:]+):%s*(.*)")
		if not name then
			break
		end
		local t = {}
		for lower, upper, keyword in rule_str:gmatch("(%d+)-(%d+)%s*(%a*)") do
			assert(keyword == nil or keyword == "" or keyword == "or") -- let's hope we don't have to change for part 2
			table.insert(t, { lower = tonumber(lower), upper = tonumber(upper) })
		end
		rules[name] = t
		count = count + 1
	end
	log.progress("parsed ", count, " rules")

	log.debug("parsing your ticket")
	local s = f:read("l")
	assert(s == "your ticket:")
	local your_ticket = {}
	for n in f:read("l"):gmatch("(%d+)[,]?") do
		table.insert(your_ticket, tonumber(n))
	end

	log.debug("parsing nearby tickets")
	f:read("l")
	s = f:read("l")
	assert(s == "nearby tickets:")
	local nearby_tickets = {}
	for line in f:lines() do
		local t = {}
		for n in line:gmatch("%d+") do
			table.insert(t, tonumber(n))
		end
		table.insert(nearby_tickets, t)
	end

	f:close()
	return {
		rules = rules,
		your_ticket = your_ticket,
		nearby_tickets = nearby_tickets,
	}
end

local input = read_input()
local function part1()
	local rules = input.rules
	local invalid_value_count = 0
	for i, ticket in ipairs(input.nearby_tickets) do
		log.progress("processing ticket ", i)
		for _, n in ipairs(ticket) do
			local is_valid = false
			for name, rule_defs in pairs(rules) do
				for _, rr in ipairs(rule_defs) do
					if rr.lower <= n and n <= rr.upper then
						log.debug("accepting number ", n, " due to rule ", name)
						is_valid = true
					end
				end
			end

			if is_valid == false then
				log.info("rejecting number ", n)
				invalid_value_count = invalid_value_count + n
			end
		end
	end
	return invalid_value_count
end

local function part2()
	local rules = input.rules
	local valid_tickets = {}
	for i, ticket in ipairs(input.nearby_tickets) do
		log.progress("processing ticket ", i)
		local is_ticket_valid = true

		for _, n in ipairs(ticket) do
			local is_valid = false
			for name, rule_defs in pairs(rules) do
				for _, rr in ipairs(rule_defs) do
					if rr.lower <= n and n <= rr.upper then
						log.debug("accepting number ", n, " due to rule ", name)
						is_valid = true
						goto continue
					end
				end
			end
			::continue::
			is_ticket_valid = is_ticket_valid and is_valid
		end

		if is_ticket_valid then
			log.progress("ticket ", i, " is valid")
			table.insert(valid_tickets, ticket)
		end
	end

	local candidates = {}
	for _, _ in pairs(rules) do
		local t = {}
		for name, _ in pairs(rules) do
			table.insert(t, name)
		end
		table.insert(candidates, t)
	end
	log.debug("Candidates:")
	for i, vals in ipairs(candidates) do
		for _, name in ipairs(vals) do
			log.debug(i, ": ", name)
		end
	end
	-- walk through list and eliminate candidates
	for _, tck in ipairs(valid_tickets) do
		for i, n in ipairs(tck) do
			local ith_candidates = candidates[i]
			-- check which of these rules are violated by the number n
			for j, rule_name in pairs(ith_candidates) do
				log.debug("Checking if rule ", rule_name, " is violated by number ", n)
				local is_ok = false
				for _, rule_def in ipairs(rules[rule_name]) do
					is_ok = is_ok or (rule_def.lower <= n and n <= rule_def.upper)
				end
				if not is_ok then
					log.debug("Rule ", rule_name, " is violated by number ", n)
					table.remove(ith_candidates, j)
				end
			end
		end
	end

	local final_assignments = {}
	repeat
		-- eliminate further candidates
		-- find unique assignment
		for i, vals in ipairs(candidates) do
			if #vals == 1 then
				local rname = vals[1]
				log.debug("Assignment: '", i, " -> ", rname, "' is unique")
				final_assignments[i] = rname
			end
		end
		-- remove final assignments from other rules
		for num, rname in pairs(final_assignments) do
			log.debug("Removing rule: ", num, " name: ", rname, " from other rules")
			for i, vals in ipairs(candidates) do
				if i ~= num then
					local id_to_remove
					for k, v in ipairs(vals) do
						if v == rname then
							id_to_remove = k
							break
						end
					end
					if id_to_remove then
						log.debug("removing id ", id_to_remove)
						table.remove(vals, id_to_remove)
					end
				end
			end
		end

		--- are we done?
		local done = true
		for _, vals in ipairs(candidates) do
			done = done and #vals == 1
		end
	until done

	local assignment = {}
	for i, vals in ipairs(candidates) do
		if #vals == 1 then
			local rname = vals[1]
			assignment[rname] = i
			log.debug("Assignment: '", i, " -> ", rname, "' is unique")
		end
	end

	local your_ticket = input.your_ticket
	local answer = 1
	for k, v in pairs(assignment) do
		if k:match("^departure") then
			answer = answer * your_ticket[v]
		end
	end
	return answer
end

local answer1 = part1()
print("Part 1:", answer1)
local answer2 = part2()
print("Part 2:", answer2)

assert(answer1 == 19240)
assert(answer2 == 21095351239483)
