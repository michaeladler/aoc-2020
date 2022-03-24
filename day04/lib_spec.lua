local lib = require("lib")
local parse_pp_line = lib.parse_pp_line
local has_required_fields = lib.has_required_fields

describe("Day 4", function()
	describe("has_required_fields", function()
		it("should accept a valid passports", function()
			local pp = {}
			parse_pp_line(pp, "ecl:gry pid:860033327 eyr:2020 hcl:#fffffd")
			parse_pp_line(pp, "byr:1937 iyr:2017 cid:147 hgt:183cm")
			assert.True(has_required_fields(pp))

			pp = {}
			parse_pp_line(pp, "hcl:#ae17e1 iyr:2013")
			parse_pp_line(pp, "eyr:2024")
			parse_pp_line(pp, "ecl:brn pid:760753108 byr:1931")
			parse_pp_line(pp, "hgt:179cm")
			assert.True(has_required_fields(pp))
		end)

		it("should reject invalid passports", function()
			local pp = {}
			parse_pp_line(pp, "iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884")
			parse_pp_line(pp, "hcl:#cfa07d byr:1929")
			assert.False(has_required_fields(pp))

			pp = {}
			parse_pp_line(pp, "hcl:#cfa07d eyr:2025 pid:166559648")
			parse_pp_line(pp, "iyr:2011 ecl:brn hgt:59in")
			assert.False(has_required_fields(pp))
		end)
	end)
end)
