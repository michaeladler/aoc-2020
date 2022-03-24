local M = {}

local log = function(...)
	-- print(...)
end

local function trim(s)
	return string.gsub(s, "^%s*(.-)%s*$", "%1")
end

local function parse_pp_line(t, line)
	for k, v in string.gmatch(line, "(%S+):(%S+)%s*") do
		t[k] = v
	end
end
M.parse_pp_line = parse_pp_line

local function new_pp()
	local mt = {
		__tostring = function(t)
			return string.format(
				"Passport { byr: %s, iyr: %s, eyr: %s, hgt: %s, hcl: %s, ecl: %s, pid: %s }",
				t.byr,
				t.iyr,
				t.eyr,
				t.hgt,
				t.hcl,
				t.ecl,
				t.pid
			)
		end,
	}
	return setmetatable({}, mt)
end

local function read_input()
	local passports = {}
	local f = io.open("input.txt")
	local current_pp = nil
	local pp_count = 0
	for line in f:lines() do
		line = trim(line)
		local n = #line
		if n == 0 then
			table.insert(passports, current_pp)
			current_pp = nil
			pp_count = pp_count + 1
		end
		current_pp = current_pp or new_pp()
		parse_pp_line(current_pp, line)
	end
	-- do not forget last passport!
	if current_pp then
		table.insert(passports, current_pp)
	end
	f:close()
	log(string.format(">> Parsed %d passports", pp_count))
	return passports
end
M.read_input = read_input

local REQUIRED_FIELDS = { "byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid" } -- cid is optional
local function has_required_fields(passport)
	for _, fld in ipairs(REQUIRED_FIELDS) do
		if passport[fld] == nil then
			log(string.format(">> Field %s missing", fld))
			return false
		end
	end
	return true
end
M.has_required_fields = has_required_fields

local function count(passports, cb)
	local count_ok = 0
	for i, v in pairs(passports) do
		if cb(v) then
			log(string.format(">> Accepting passport number %d: %s", i, v))
			count_ok = count_ok + 1
		else
			log(string.format(">> Rejecting passport number %d: %s", i, v))
		end
	end
	return count_ok
end

local function part1(passports)
	return count(passports, has_required_fields)
end
M.part1 = part1

local function check_byr(byr)
	-- byr (Birth Year) - four digits; at least 1920 and at most 2002.
	byr = string.match(byr, "^%d%d%d%d$")
	if byr == nil then
		log("byr failed")
		return false
	end
	byr = tonumber(byr)
	if not (byr ~= nil and byr >= 1920 and byr <= 2002) then
		log("byr failed")
		return false
	end
	return true
end

local function check_iyr(iyr)
	-- iyr (Issue Year) - four digits; at least 2010 and at most 2020.
	iyr = string.match(iyr, "^%d%d%d%d$")
	if iyr == nil then
		log("iyr failed")
		return false
	end
	iyr = tonumber(iyr)
	if not (iyr ~= nil and iyr >= 2010 and iyr <= 2020) then
		log("iyr failed")
		return false
	end
	return true
end

local function check_eyr(eyr)
	-- eyr (Expiration Year) - four digits; at least 2020 and at most 2030.
	eyr = string.match(eyr, "^%d%d%d%d$")
	if eyr == nil then
		log("eyr failed:", eyr)
		return false
	end
	eyr = tonumber(eyr)
	if not (eyr ~= nil and eyr >= 2020 and eyr <= 2030) then
		log("eyr failed:", eyr)
		return false
	end
	return true
end

local function check_hgt(hgt)
	local ok = true
	-- hgt (Height) - a number followed by either cm or in:
	local amount, unit = string.match(hgt, "^(%d+)([a-z][a-z])$")
	ok = ok and (amount ~= nil and (unit == "cm" or unit == "in"))
	amount = tonumber(amount)
	if unit == "cm" then
		-- If cm, the number must be at least 150 and at most 193.
		ok = ok and (amount >= 150 and amount <= 193)
	else
		-- If in, the number must be at least 59 and at most 76.
		ok = ok and (amount >= 59 and amount <= 76)
	end
	if not ok then
		log("hgt failed:", hgt)
		return false
	end
	return true
end

local function check_hcl(hcl)
	-- hcl (Hair Color) - a # followed by exactly six characters 0-9 or a-f.
	local ok = true
	local a, b = string.find(hcl, "^#[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]$")
	ok = ok and a ~= nil and b ~= nil
	if not ok then
		log("hcl failed:", hcl)
		return false
	end
	return true
end

local function check_ecl(ecl)
	-- ecl (Eye Color) - exactly one of: amb blu brn gry grn hzl oth.
	if
		not (
			ecl == "amb"
			or ecl == "blu"
			or ecl == "brn"
			or ecl == "gry"
			or ecl == "grn"
			or ecl == "hzl"
			or ecl == "oth"
		)
	then
		log("ecl failed:", ecl)
		return false
	end
	return true
end

local function check_pid(pid)
	-- pid (Passport ID) - a nine-digit number, including leading zeroes.
	local a, b = string.find(pid, "^%d%d%d%d%d%d%d%d%d$")
	if a == nil or b == nil then
		log("pid failed:", pid)
		return false
	end
	return true
end

local function has_valid_data(passport)
	return check_byr(passport.byr)
		and check_iyr(passport.iyr)
		and check_eyr(passport.eyr)
		and check_hgt(passport.hgt)
		and check_hcl(passport.hcl)
		and check_ecl(passport.ecl)
		and check_pid(passport.pid)
end

local function part2(passports)
	local count_ok = count(passports, function(pp)
		return has_required_fields(pp) and has_valid_data(pp)
	end)
	return count_ok
end
M.part2 = part2

return M
