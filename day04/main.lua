#!/usr/bin/env luajit

local lib = require("lib")

local passports = lib.read_input()
local answer1 = lib.part1(passports)
local answer2 = lib.part2(passports)

print("Part 1:", answer1)
print("Part 2:", answer2)

assert(answer1 == 210)
assert(answer2 == 131)
