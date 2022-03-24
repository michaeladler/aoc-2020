local combinatorics = require "combinatorics"

describe("combinatorics", function()
  describe("permutations", function()
    it("should generate all permutations (non-empty)", function()
      local t = {1, 2, 3}
      local expected = {
        {1, 2, 3}, {2, 1, 3}, {3, 1, 2}, {1, 3, 2}, {2, 3, 1}, {3, 2, 1}
      }
      local count = 0
      for perm in combinatorics.permutations(t) do
        assert.are.same(expected[1 + count], perm)
        count = count + 1
      end
      assert.are.equal(6, count)
    end)

    it("should work on empty objects", function()
      local t = {}
      for _ in combinatorics.permutations(t) do
        -- unreachable
        assert.False(true)
      end
    end)

    it("should work for a single object", function()
      local t = {"a"}
      local count = 0
      for perm in combinatorics.permutations(t) do
        assert.are.same({"a"}, perm)
        count = count + 1
      end
      assert.are.equal(1, count)
    end)

  end)

end)
