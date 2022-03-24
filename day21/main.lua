#!/usr/bin/env luajit

-- Copyright 2020, Michael Adler <therisen06@gmail.com>
local log = require("log")
log.level = "error"

-- local fname = "small.txt"
local fname = "input.txt"

local Map = require("pl.Map")
local Set = require("pl.Set")

local combinatorics = require("aoc.combinatorics")
local permutations = combinatorics.permutations

local function read_input()
	local f = io.open(fname, "r")
	local rules = Map({})
	for line in f:lines() do
		local lhs, rhs = line:match("(.*)%(contains (.*)%)")
		local ingredients = Set({})
		for s in lhs:gmatch("%w+") do
			ingredients = ingredients + s
		end
		local allergies = Set({})
		for s in rhs:gmatch("%w+") do
			allergies = allergies + s
		end
		rules:set(ingredients, allergies)
	end
	f:close()
	return rules
end

local function has_contradiction(rules, ingredient, allergen)
	log.progress("Checking rules for assignment: ", ingredient, " -> ", allergen)
	for ings, allergies in rules:iter() do
		if not ings[ingredient] and Set.len(allergies) == 1 and allergies[allergen] then
			log.progress("Found contradiction with ingredients: ", tostring(ings), " allergens: ", tostring(allergies))
			return true
		end
		if allergies[allergen] and not ings[ingredient] then
			log.progress("Found contradiction with ingredients: ", tostring(ings), " allergens: ", tostring(allergies))
			return true
		end
	end
	log.progress("No contradiction")
	return false
end

local function determine_safe_ingredients(rules)
	-- map food to possible allergies
	local all_ingredients = Map({})
	for ings, allergies in rules:iter() do
		for s in Set.values(ings):iter() do
			local set = all_ingredients:get(s) or Set({})
			for x in Set.values(allergies):iter() do
				set = set + x
			end
			all_ingredients:set(s, set)
		end
	end
	log.debug("Found ", all_ingredients:len(), " ingredients: ", tostring(all_ingredients))
	local safe_ingredients = Set({})
	for ing, allergies in all_ingredients:iter() do
		log.debug("ing: ", tostring(ing))
		log.debug("allergies: ", tostring(allergies))
		local is_safe = true
		for a in Set.values(allergies):iter() do
			is_safe = is_safe and has_contradiction(rules, ing, a)
			if not is_safe then
				break
			end
		end
		if is_safe then
			safe_ingredients = safe_ingredients + ing
		end
	end
	return safe_ingredients
end

local rules = read_input()
-- ingredients which do not contain any allergen
local safe_ingredients = determine_safe_ingredients(rules)

local function part1()
	-- Counting the number of times any of these ingredients appear in any ingredients list
	local count = 0
	for ing in Set.values(safe_ingredients):iter() do
		for ings in rules:keys():iter() do
			if ings[ing] then
				count = count + 1
			end
		end
	end
	return count
end

local function part2()
	local assignment = Map({})
	local all_allergens = Set({})
	for ingredients, allergens in rules:iter() do
		for ing in Set.values(ingredients - safe_ingredients):iter() do
			all_allergens = all_allergens + allergens
			assignment:set(ing, true)
		end
	end

	local rev_assignment = Map({})
	all_allergens = Set.values(all_allergens)
	for p in permutations(all_allergens) do
		local i = 1
		for k, _ in pairs(assignment) do
			local a = p[i]
			assignment[k] = a
			rev_assignment:set(a, k)
			i = i + 1
		end
		local is_ok = true
		for ingredients, allergens in rules:iter() do
			for alg in Set.values(allergens):iter() do
				-- Allergens aren't always marked; when they're listed (as in (contains
				-- nuts, shellfish) after an ingredients list), the ingredient that
				-- contains each listed allergen will be somewhere in the corresponding
				-- ingredients list.
				is_ok = is_ok and ingredients[rev_assignment:get(alg)]
			end
		end
		if is_ok then
			break
		end
	end

	log.progress("Found assignment: ", tostring(assignment))
	local ingredients = assignment:keys()
	ingredients:sort(function(ing1, ing2)
		return assignment:get(ing1) < assignment:get(ing2)
	end)
	return ingredients:join(",")
end

local answer1 = part1()
print("Part 1:", answer1)
local answer2 = part2()
print("Part 2:", answer2)

assert(answer1 == 1882)
assert(answer2 == "xgtj,ztdctgq,bdnrnx,cdvjp,jdggtft,mdbq,rmd,lgllb")
