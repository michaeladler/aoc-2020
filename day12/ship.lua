local log = require 'log'

local M = {}

local function dir2ang(dir)
  if dir == "N" then
    return 0
  elseif dir == "E" then
    return 90
  elseif dir == "S" then
    return 180
  elseif dir == "W" then
    return 270
  end
  error(string.format("Invalid direction: %s", dir))
end

local function ang2dir(ang)
  local a = ang % 360
  if a == 0 then
    return "N"
  elseif a == 90 then
    return "E"
  elseif a == 180 then
    return "S"
  elseif a == 270 then
    return "W"
  end
  error(string.format("Invalid angle: %d", a))
end

local function rotate(direction, orient, ang)
  -- orient can be L Or R, ang is a number (degress)
  local sign
  if orient == "L" then
    sign = -1
  elseif orient == "R" then
    sign = 1
  else
    error(string.format("Invalid orient: %s", orient))
  end
  local new_ang = dir2ang(direction) + sign * ang
  local new_dir = ang2dir(new_ang)
  log.debug("Changing direction from ", direction, " to ", new_dir)
  return new_dir
end

local function advance(ship, action, value)
  local state = ship.state
  if action == "L" or action == "R" then
    ship.state.direction = rotate(ship.state.direction, action, value)
    return
  end

  local dir = action
  if action == "F" then dir = state.direction end
  log.progress("advancing in direction ", dir, " ", value, " steps")
  state[dir] = state[dir] + value
end

local function manhattan_dist(ship)
  local state = ship.state
  return math.abs(state.N - state.S) + math.abs(state.E - state.W)
end

local function advance2(ship, action, value)
  log.progress("Processing: ", action, value)
  local waypoint = ship.waypoint
  local dir = action
  -- easy cases first
  if action == "N" or action == "S" or action == "E" or action == "W" then
    log.debug("Before waypoint: ", tostring(ship.waypoint))
    waypoint[dir] = waypoint[dir] + value
    log.debug("After  waypoint: ", tostring(ship.waypoint))
  elseif action == "F" then
    local state = ship.state
    local mult = value
    log.debug("Before state: ", tostring(ship.state))
    state.N = state.N + waypoint.N * mult
    state.S = state.S + waypoint.S * mult
    state.E = state.E + waypoint.E * mult
    state.W = state.W + waypoint.W * mult
    log.debug("After  state: ", tostring(ship.state))
  elseif action == "L" or action == "R" then
    local rot_map = {}
    rot_map[rotate("N", action, value)] = "N"
    rot_map[rotate("S", action, value)] = "S"
    rot_map[rotate("E", action, value)] = "E"
    rot_map[rotate("W", action, value)] = "W"
    log.debug("rot_map: N=", rot_map.N, " S=", rot_map.S, " E=", rot_map.E, " W=", rot_map.W)
    local old = {N = waypoint.N, E = waypoint.E, S = waypoint.S, W = waypoint.W}
    log.debug("Before waypoint: ", tostring(ship.waypoint))
    waypoint.N = old[rot_map.N]
    waypoint.S = old[rot_map.S]
    waypoint.E = old[rot_map.E]
    waypoint.W = old[rot_map.W]
    log.debug("After  waypoint: ", tostring(ship.waypoint))
  end
end

function new()
  local state = setmetatable({direction = "E", N = 0, E = 0, S = 0, W = 0}, {
    __tostring = function(t)
      return string.format("{ direction=%s, N=%s, E=%s, S=%s, W=%s }", t.direction,
                           t.N, t.E, t.S, t.W)
    end
  })
  local waypoint = setmetatable({N = 1, E = 10, S = 0, W = 0}, {
    __tostring = function(t)
      return string.format("{ N=%s, E=%s, S=%s, W=%s }", t.N, t.E, t.S, t.W)
    end
  })
  return {
    state = state,
    advance = advance,
    manhattan_dist = manhattan_dist,
    waypoint = waypoint,
    advance2 = advance2
  }
end

M.new = new

return M
