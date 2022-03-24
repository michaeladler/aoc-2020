#!/usr/bin/env luajit

require("algo")

local max_seat_id = -math.huge
local seats = {}
for i = 0, seat_id(127, 7) do
	seats[i] = false -- not occupied
end

local f = io.open("input.txt", "r")
for line in f:lines() do
	local row, col = decode(line)
	local seat_id = seat_id(row, col)
	seats[seat_id] = true
	if seat_id > max_seat_id then
		max_seat_id = seat_id
	end
end
f:close()

print("Part 1:", max_seat_id)
assert(max_seat_id == 978)

local part2
for k, _ in pairs(seats) do
	-- is seat k free?
	local is_free = seats[k] == false
	-- the seats with IDs +1 and -1 from yours will be in your list.
	if is_free and seats[k + 1] == true and seats[k - 1] == true then
		part2 = k
		break
	end
end

print("Part 2:", part2)
assert(part2 == 727)
