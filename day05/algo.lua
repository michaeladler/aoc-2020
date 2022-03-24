local floor = math.floor
local ceil = math.ceil

function seat_id(row, col) return row * 8 + col end

local function binwalk(lower, upper, is_up)
  local mid = (upper + lower) / 2
  if is_up then
    lower = ceil(mid)
  else
    upper = floor(mid)
  end
  return lower, upper
end

function decode(s)
  local upper = 127
  local lower = 0

  local n = #s
  -- The last three characters will be either L or R
  for i = 1, n - 3 do
    local c = s:sub(i, i)
    assert(c == "F" or c == "B")
    local is_up = c == "B"
    lower, upper = binwalk(lower, upper, is_up)
  end
  assert(lower == upper, "lower must be the same as upper")
  local row = upper

  upper = 7
  lower = 0
  -- The last three characters will be either L or R
  for i = n - 2, n do
    local c = s:sub(i, i)
    assert(c == "L" or c == "R")
    local is_up = c == "R"
    lower, upper = binwalk(lower, upper, is_up)
  end
  assert(lower == upper, "lower must be the same as upper")
  local col = upper

  return row, col
end

