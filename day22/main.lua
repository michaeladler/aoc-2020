#!/usr/bin/env luajit

-- Copyright 2020, Michael Adler <therisen06@gmail.com>
local log = require("log")
log.level = "error"

local List = require("pl.List")
local class = require("pl.class")

-- local fname = "small.txt"
local fname = "input.txt"

local function read_input()
	local f = io.open(fname, "r")
	local p1, p2 = List({}), List({})
	local ignore = f:read("*l")
	assert(ignore ~= nil)
	for line in f:lines() do
		if line == "" then
			goto continue
		end
		if line == "Player 2:" then
			break
		end
		p1:append(assert(tonumber(line)))
		::continue::
	end
	for line in f:lines() do
		p2:append(assert(tonumber(line)))
	end
	f:close()
	return p1, p2
end

local function compute_score(t1, t2)
	local t = t1
	if t[1] == nil then
		t = t2
	end
	local n = #t
	local score = 0
	for i = 1, n do
		score = score + (n - i + 1) * t[i]
	end
	return score
end

local function part1()
	local cards1, cards2 = read_input()
	while cards1[1] ~= nil and cards2[1] ~= nil do
		local c1 = cards1:pop(1)
		local c2 = cards2:pop(1)
		log.progress("New round: Player 1: ", c1, ", Player 2: ", c2)
		if c1 > c2 then
			log.debug("Player 1 wins")
			cards1:append(c1)
			cards1:append(c2)
		else
			log.debug("Player 2 wins")
			cards2:append(c2)
			cards2:append(c1)
		end
	end
	return compute_score(cards1, cards2)
end

local Game = class()
function Game:_init(game_id, cards1, cards2)
	self.game_id = game_id
	self.cards1 = cards1
	self.cards2 = cards2
	self.history = {}
	self.winner = nil
	self.round = 0
	log.debug(string.format("=== Game %d ===\n", game_id))
end

function Game:check_finished()
	if self.winner == nil then
		if self.cards1[1] == nil then
			log.debug("Player 1 has no cards left")
			self.winner = 2
		elseif self.cards2[1] == nil then
			log.debug("Player 2 has no cards left")
			self.winner = 1
		end
	end
	return self.winner ~= nil
end

function Game:check_cycle()
	-- check if we've seen this state before
	if self.history[self:serialize_cards()] then
		self.winner = 1
		return true
	end
	return false
end

function Game:serialize_cards()
	return string.format("%s %s", tostring(self.cards1), tostring(self.cards2))
end

function Game:deal_cards()
	self.round = self.round + 1
	log.progress(string.format("-- Round %d (Game %d) --", self.round, self.game_id))
	log.debug("Player 1's deck: ", tostring(self.cards1))
	log.debug("Player 2's deck: ", tostring(self.cards2))

	self.history[self:serialize_cards()] = true
	local c1, c2 = self.cards1:pop(1), self.cards2:pop(1)
	log.debug("Player 1 plays: ", c1)
	log.debug("Player 2 plays: ", c2)
	return c1, c2
end

local function part2()
	local cards1, cards2 = read_input()
	local current = Game(1, cards1, cards2)
	-- "stack" frames / suspended games
	local frames = {}
	local winner

	while true do
		if current:check_finished() or current:check_cycle() then
			winner = current.winner
			log.debug(string.format("Player %d wins round %d of game %d!", winner, current.round, current.game_id))
			if frames[1] == nil then
				log.progress("Game over")
				break
			else
				-- pop parent game
				local frm = table.remove(frames, #frames)
				current = frm.game
				local c1, c2 = frm.c1, frm.c2
				if winner == 1 then
					current.cards1:append(c1)
					current.cards1:append(c2)
				else
					current.cards2:append(c2)
					current.cards2:append(c1)
				end
			end
		else
			-- this round's cards must be in a new configuration
			local c1, c2 = current:deal_cards()
			-- If both players have at least as many cards remaining in their deck as
			-- the value of the card they just drew, the winner of the round is
			-- determined by playing a new game of Recursive Combat
			if #current.cards1 >= c1 and #current.cards2 >= c2 then
				log.debug("Playing a sub-game to determine the winner...")
				table.insert(frames, { game = current, c1 = c1, c2 = c2 })
				-- the quantity of cards copied is equal to the number on the card they
				-- drew to trigger the sub-game
				current = Game(current.game_id + 1, current.cards1:slice(1, c1), current.cards2:slice(1, c2))
			else
				-- Otherwise, at least one player must not have enough cards left in
				-- their deck to recurse; the winner of the round is the player with the
				-- higher-value card.
				if c1 > c2 then
					log.debug(string.format("Player 1 wins round %d of game %d!", current.round, current.game_id))
					current.cards1:append(c1)
					current.cards1:append(c2)
				else
					log.debug(string.format("Player 2 wins round %d of game %d!", current.round, current.game_id))
					current.cards2:append(c2)
					current.cards2:append(c1)
				end
			end
		end
	end
	return compute_score(cards1, cards2)
end

local answer1 = part1()
print("Part 1:", answer1)
local answer2 = part2()
print("Part 2:", answer2)

assert(answer1 == 33680)
assert(answer2 == 33683)
