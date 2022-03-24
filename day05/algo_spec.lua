require 'algo'

describe("Day 5", function()
  describe("decode", function()
    it("should decode FBFBBFFRLR", function()
      local row, col = decode("FBFBBFFRLR")
      assert.are.equal(44, row)
      assert.are.equal(5, col)
    end)

    it("should decode BFFFBBFRRR", function()
      local row, col = decode("BFFFBBFRRR")
      assert.are.equal(70, row)
      assert.are.equal(7, col)
    end)

    it("should decode FFFBBBFRRR", function()
      local row, col = decode("FFFBBBFRRR")
      assert.are.equal(14, row)
      assert.are.equal(7, col)
    end)

    it("should decode BBFFBBFRLL", function()
      local row, col = decode("BBFFBBFRLL")
      assert.are.equal(102, row)
      assert.are.equal(4, col)
    end)

  end)

  describe("seat_id", function()
    it("should calculate the seat id",
       function() assert.are.equal(567, seat_id(70, 7)) end)

  end)
end)
