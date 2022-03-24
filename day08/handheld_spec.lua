local handheld = require 'handheld'
local stringio = require 'pl.stringio'
local log = require 'log'
log.level = "error"

describe("handheld", function()
  it("should parse and run a simple program", function()
    local text = [[nop +0
acc +1
jmp +4
acc +3
jmp -3
acc -99
acc +1
nop -4
acc +6
]]
    local f = stringio.open(text)
    local program = handheld.parse(f)
    assert.are.equal(9, #program.instructions)
    assert.are.equal(1, program.ip)
    assert.are.equal(0, program.accumulator)

    local result = program:run()
    assert.are.equal(8, result)
  end)

end)
