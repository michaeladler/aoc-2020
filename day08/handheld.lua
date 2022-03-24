local tablex = require 'pl.tablex'
local log = require 'log'

local M = {}

local function new()
  local function step(self)
    --- Run the next instruction.

    local ip = self.ip
    local acc = self.accumulator

    local instruction = self.instructions[ip]
    local op, arg = instruction.operation, instruction.argument
    log.debug("Running: ", op, " ", arg)

    if op == "nop" then
      -- nop stands for No OPeration - it does nothing.
      ip = ip + 1
    elseif op == "jmp" then
      -- jmp jumps to a new instruction relative to itself
      ip = ip + tonumber(arg)
    elseif op == "acc" then
      -- acc increases or decreases a single global value called the accumulator by the value given in the argument
      acc = acc + tonumber(arg)
      ip = ip + 1
    end

    -- update program
    log.progress("old ip: ", self.ip, " new ip:", ip, " old acc: ",
                 self.accumulator, " new acc: ", acc)
    self.ip = ip
    self.accumulator = acc
  end

  local function clone(self) return tablex.deepcopy(self) end

  local function is_terminated(self) return self.ip > #self.instructions end

  local function run(self)
    while not self:is_terminated() do self:step() end
    return self.accumulator
  end

  return {
    accumulator = 0,
    instructions = {},
    ip = 1,
    -- functions
    step = step,
    is_terminated = is_terminated,
    run = run,
    clone = clone
  }
end
M.new = new

local function parse(code)
  local program = new()

  local instructions = program.instructions
  for line in code:lines() do
    -- Each instruction consists of an operation (acc, jmp, or nop) and an argument (a signed number like +4 or -20).
    local operation, argument = line:match("(%S+)%s+(%S+)")
    if operation == nil or argument == nil then return nil end
    table.insert(instructions, {operation = operation, argument = argument})
  end
  return program
end
M.parse = parse

return M
