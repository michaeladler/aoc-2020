local Graph = require 'graph'

describe("graph", function()
  describe("ford_fulkerson", function()
    it("should compute the maximum flow", function()
      -- LuaFormatter off
      local adj = {
        {0, 16, 13, 0, 0, 0},
        {0, 0, 10, 12, 0, 0},
        {0, 4, 0, 0, 14, 0},
        {0, 0, 9, 0, 0, 20},
        {0, 0, 0, 7, 0, 4},
        {0, 0, 0, 0, 0, 0}
      }
      -- LuaFormatter on
      local g = Graph.new(adj)
      local source, sink = 1, 6
      local max_flow, residual_graph = g:max_flow(source, sink)
      assert.are.equal(23, max_flow)

      -- LuaFormatter off
      local expected = {
        {0, 4, 2, 0, 0, 0,},
        {0, 0, 10, 0, 0, 0},
        {0, 4, 0, 0, 3, 0},
        {0, 0, 9, 0, 0, 1},
        {0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0},
      }
      -- LuaFormatter on
      assert.are.same(expected, residual_graph)
    end)

  end)
end)
