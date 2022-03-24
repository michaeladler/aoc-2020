local matrix = require 'matrix'

describe("matrix", function()
  describe("rotate", function()
    it("should rotate a matrix", function()
      local m = {{'a', 'b', 'c'}, {'d', 'e', 'f'}, {'g', 'h', 'i'}}

      matrix.rotate(m)

      local expected = {{'c', 'f', 'i'}, {'b', 'e', 'h'}, {'a', 'd', 'g'}}
      assert.are.same(expected, m)
    end)

    it("should be 4-cyclic", function()
      local m = {{'a', 'b', 'c'}, {'d', 'e', 'f'}, {'g', 'h', 'i'}}

      matrix.rotate(m)
      matrix.rotate(m)
      matrix.rotate(m)
      matrix.rotate(m)

      -- same as m
      local expected = {{'a', 'b', 'c'}, {'d', 'e', 'f'}, {'g', 'h', 'i'}}
      assert.are.same(expected, m)
    end)
  end)

  describe("flip", function()
    it("should flip a matrix", function()
      local m = {{'a', 'b', 'c'}, {'d', 'e', 'f'}, {'g', 'h', 'i'}}
      matrix.flip(m)
      local expected = {{'g', 'h', 'i'}, {'d', 'e', 'f'}, {'a', 'b', 'c'}}
      assert.are.same(expected, m)

      m = {{'a'}, {'b'}, {'c'}, {'d'}}
      matrix.flip(m)
      expected = {{'d'}, {'c'}, {'b'}, {'a'}}
      assert.are.same(expected, m)
    end)

  end)

end)
