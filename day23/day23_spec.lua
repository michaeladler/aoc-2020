local day23 = require("day23")

describe("day23", function()
	describe("Part 1", function()
		it("should work for the sample input", function()
			assert.are.equal(92658374, day23.part1("389125467", 10))
			assert.are.equal(67384529, day23.part1("389125467", 100))
		end)

		it("should work for the real input", function()
			-- my input
			assert.are.equal(25398647, day23.part1("952316487", 100))
		end)
	end)

	describe("Part 2", function()
		it("should work for the sample input", function()
			assert.are.equal(149245887792, day23.part2("389125467"))
		end)

		it("should work for the real input", function()
			assert.are.equal(363807398885, day23.part2("952316487", 100))
		end)
	end)
end)
