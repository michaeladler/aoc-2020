#! /usr/bin/env lua

-- Copyright 2020, Michael Adler <therisen06@gmail.com>

local fname = "input.txt"
-- local fname = "small2.txt"

local function set_bit(value, n) return value | (1 << n) end

local function clear_bit(value, n) return value & ~(1 << n) end

local function apply_bitmask(bitmask, value)
  local result = value
  local n = 0
  for i = #bitmask, 1, -1 do
    local c = bitmask:sub(i, i)
    if c == "0" then
      result = clear_bit(result, n)
    elseif c == "1" then
      result = set_bit(result, n)
    end
    n = n + 1
  end
  --log.debug("Applied bitmask ", bitmask, " to ", value, ": ", result)
  return result
end

local function apply_bitmask2(bitmask, value)
  local result = value
  local floating_bits = {}
  local n = 0
  for i = #bitmask, 1, -1 do
    local c = bitmask:sub(i, i)
    if c == "1" then
      result = set_bit(result, n)
    elseif c == "X" then
      table.insert(floating_bits, n)
    end
    n = n + 1
  end
  --log.debug("Applied bitmask ", bitmask, " to ", value, ": ", result)
  return result, floating_bits
end

local function parse_line(line)
  local mask = line:match("mask%s+=%s+(%w+)")
  if mask then return mask, nil, nil end
  local addr, value = line:match("mem%[(%d+)%]%s+=%s+(%d+)")
  return nil, tonumber(addr), tonumber(value)
end

local function sum_values(t)
  local sum = 0
  for _, v in pairs(t) do sum = sum + v end
  return sum
end

local function read_input(bitmask_fn)
  local f = io.open(fname, "r")
  local current_mask, memory = nil, {}
  for line in f:lines() do
    local mask, addr, value = parse_line(line)
    if mask then
      --log.debug("Setting new bitmask: ", mask)
      current_mask = mask
    else
      bitmask_fn(memory, current_mask, addr, value)
    end
  end
  f:close()
  return memory
end

local function part1()
  local memory = read_input(function(memory, bitmask, addr, value)
    memory[addr] = apply_bitmask(bitmask, value)
  end)
  return sum_values(memory)
end

local function process_floating(addr, floating_bits)
  local n = #floating_bits
  if n == 0 then return {} end
  local pos = table.remove(floating_bits)
  if n == 1 then return {clear_bit(addr, pos), set_bit(addr, pos)} end
  local t = {}
  for _, x in ipairs(process_floating(addr, floating_bits)) do
    table.insert(t, clear_bit(x, pos))
    table.insert(t, set_bit(x, pos))
  end
  return t
end

local function part2()
  local memory = read_input(function(memory, bitmask, addr, value)
    local new_addr, floating_bits = apply_bitmask2(bitmask, addr)
    --log.debug("Processing ", #floating_bits, " floating bits for addr ", new_addr)
    for _, generated_addr in ipairs(process_floating(new_addr, floating_bits)) do
      --log.debug("Setting value in addr ", generated_addr)
      memory[generated_addr] = value
    end
  end)
  return sum_values(memory)
end

local answer1 = part1()
print("Part 1:", answer1)
local answer2 = part2()
print("Part 2:", answer2)

assert(answer1 == 12135523360904)
assert(answer2 == 2741969047858)
