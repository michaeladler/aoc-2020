local log = require 'log'

local M = {}

-- local FLOOR = "."
local EMPTY_SEAT = "L"
local OCCUPIED_SEAT = "#"

-- one of the eight positions immediately up, down, left, right, or diagonal from the seat
local directions = {}
for i = -1, 1 do
  for j = -1, 1 do
    if i == 0 and j == 0 then goto continue end
    table.insert(directions, {dx = i, dy = j})
    ::continue::
  end
end

local function is_occupied(seatingsystem, x, y)
  return seatingsystem.grid[x][y] == OCCUPIED_SEAT
end

local function adjacent_seats(seatingsystem, x, y)
  local neighbors = {}
  for _, dir in ipairs(directions) do
    local i, j = dir.dx, dir.dy
    local x_neighb, y_neighb = x + i, y + j
    if x_neighb >= 1 and y_neighb >= 1 and x_neighb <= seatingsystem.max_x and
        y_neighb <= seatingsystem.max_y then
      table.insert(neighbors, {x = x_neighb, y = y_neighb})
    end
  end
  return neighbors
end

local function has_occupied_neighbor(seatingsystem, x, y)
  local grid = seatingsystem.grid
  for _, nb in pairs(seatingsystem:adjacent_seats(x, y)) do
    if grid[nb.x][nb.y] == OCCUPIED_SEAT then return true end
  end
  return false
end

local function occupied_count(seatingsystem, x, y)
  local count = 0
  for _, nb in pairs(seatingsystem:adjacent_seats(x, y)) do
    if seatingsystem:is_occupied(nb.x, nb.y) then count = count + 1 end
  end
  return count
end

local function advance(seatingsystem)
  local changes = {}
  local grid = seatingsystem.grid
  for x = 1, seatingsystem.max_x do
    for y = 1, seatingsystem.max_y do
      if grid[x][y] == EMPTY_SEAT then
        -- If a seat is empty (L) and there are no occupied seats adjacent to it, the seat becomes occupied.
        if seatingsystem:has_occupied_neighbor(x, y) == false then
          table.insert(changes, {action = OCCUPIED_SEAT, x = x, y = y})
        end
      elseif grid[x][y] == OCCUPIED_SEAT then
        -- If a seat is occupied (#) and four or more seats adjacent to it are also occupied, the seat becomes empty.
        if seatingsystem:occupied_count(x, y) >= 4 then
          table.insert(changes, {action = EMPTY_SEAT, x = x, y = y})
        end
      end
    end
  end
  for _, c in ipairs(changes) do
    local x = c.x
    local y = c.y
    log.progress("CHANGE: x=", x, ", y=", y, ": ", c.action)
    seatingsystem.grid[x][y] = c.action
  end
  return changes[1] ~= nil -- true if something was changed
end

local function count_seats(seats, kind)
  local count = 0
  for _, s in ipairs(seats) do if s == kind then count = count + 1 end end
  return count
end

local function advance2(seatingsystem)
  local changes = {}
  local grid = seatingsystem.grid
  for x = 1, seatingsystem.max_x do
    for y = 1, seatingsystem.max_y do
      if grid[x][y] == EMPTY_SEAT then
        -- empty seats that see no occupied seats become occupied
        if count_seats(seatingsystem:visible_seats(x, y), OCCUPIED_SEAT) == 0 then
          table.insert(changes, {action = OCCUPIED_SEAT, x = x, y = y})
        end
      elseif grid[x][y] == OCCUPIED_SEAT then
        -- it now takes five or more visible occupied seats for an occupied seat to become empty
        if count_seats(seatingsystem:visible_seats(x, y), OCCUPIED_SEAT) >= 5 then
          table.insert(changes, {action = EMPTY_SEAT, x = x, y = y})
        end
      end
    end
  end
  for _, c in ipairs(changes) do
    local x = c.x
    local y = c.y
    log.progress("CHANGE: x=", x, ", y=", y, ": ", c.action)
    seatingsystem.grid[x][y] = c.action
  end
  return changes[1] ~= nil -- true if something was changed
end

local function visible_seats(seatingsystem, x, y)
  local grid = seatingsystem.grid
  local seats = {}
  for _, dir in ipairs(directions) do
    local dx, dy = dir.dx, dir.dy
    local i = 1
    while true do
      local xx, yy = x + i * dx, y + i * dy
      local p = (grid[xx] or {})[yy]
      if p == nil then goto continue end
      if p == EMPTY_SEAT or p == OCCUPIED_SEAT then
        log.debug("Seat x=", x, ", y=", y, " sees: xx=", xx, ", yy=", yy,
                  ", seat=", p)
        table.insert(seats, p)
        break
      end
      i = i + 1
    end
    ::continue::
  end
  return seats
end

M.new = function(grid, max_x, max_y)
  return {
    grid = grid,
    max_x = max_x,
    max_y = max_y,
    adjacent_seats = adjacent_seats,
    has_occupied_neighbor = has_occupied_neighbor,
    advance = advance,
    advance2 = advance2,
    occupied_count = occupied_count,
    is_occupied = is_occupied,
    visible_seats = visible_seats
  }
end

return M
