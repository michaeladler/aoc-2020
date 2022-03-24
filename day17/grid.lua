local log = require 'log'

local M = {}

local ACTIVE = "#"
local INACTIVE = "."

M.ACTIVE = ACTIVE
M.INACTIVE = INACTIVE

local function is_active(grid, x, y, z) return grid:get_value(x, y, z) == ACTIVE end

-- N.B.: nil also counts as inactive
local function is_inactive(grid, x, y, z) return not is_active(grid, x, y, z) end

local function count_neighbors(grid, x, y, z)
  local active_count = 0
  for i = -1, 1 do
    for j = -1, 1 do
      for k = -1, 1 do
        if i == 0 and j == 0 and k == 0 then goto continue end
        if grid:is_active(x + i, y + j, z + k) then
          active_count = active_count + 1
        end
        ::continue::
      end
    end
  end
  return active_count
end

local function cycle(grid)
  local changes = {}
  -- grid can grow at most 2 in each dimension (x_min-1, x_max+1)
  for x = grid.x_min - 1, grid.x_max + 1 do
    for y = grid.y_min - 1, grid.y_max + 1 do
      for z = grid.z_min - 1, grid.z_max + 1 do
        local active = grid:count_neighbors(x, y, z)
        if grid:is_active(x, y, z) then
          if not (active == 2 or active == 3) then
            table.insert(changes, {x = x, y = y, z = z, status = INACTIVE})
          end
        elseif active == 3 then
          table.insert(changes, {x = x, y = y, z = z, status = ACTIVE})
        end
      end
    end
  end

  log.progress("Applying ", #changes, " changes")
  for _, action in ipairs(changes) do
    grid:set_value(action.x, action.y, action.z, action.status)
  end
end

local function set_value(grid, x, y, z, value)
  log.debug("setting x=", x, ", y=", y, ", z=", z, ", value=", value)
  if x > grid.x_max then grid.x_max = x end
  if y > grid.y_max then grid.y_max = y end
  if z > grid.z_max then grid.z_max = z end

  if x < grid.x_min then grid.x_min = x end
  if y < grid.y_min then grid.y_min = y end
  if z < grid.z_min then grid.z_min = z end

  local data = grid.data
  data[x] = data[x] or {}
  data[x][y] = data[x][y] or {}
  data[x][y][z] = value
end

local _empty = {}
local function get_value(grid, x, y, z)
  return ((grid.data[x] or _empty)[y] or _empty)[z]
end

local function show_slice(grid, z)
  local stdout = io.stdout
  for y = grid.y_min, grid.y_max do
    for x = grid.x_min, grid.x_max do
      if grid:is_active(x, y, z) then
        stdout:write(ACTIVE)
      else
        stdout:write(INACTIVE)
      end
    end
    stdout:write("\n")
  end
end

M.new = function()
  return {
    data = {},
    x_min = 0,
    x_max = 0,
    y_min = 0,
    y_max = 0,
    z_min = 0,
    z_max = 0,
    set_value = set_value,
    get_value = get_value,
    count_neighbors = count_neighbors,
    cycle = cycle,
    show_slice = show_slice,
    is_active = is_active,
    is_inactive = is_inactive
  }
end

return M
