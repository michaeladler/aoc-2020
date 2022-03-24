--
-- log.lua
--
-- Copyright (c) 2016 rxi
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.
--
local log = {_version = "0.1.0"}

log.usecolor = true
log.outfile = nil
log.level = "error"

local stderr = io.stderr

local BLUE = "\27[01;34m"
local GREEN = "\27[01;32m"
local RED = '\27[01;31m'
local GRAY = '\27[01;30m'
local DARKYELLOW = "\27[01;33m"
local NORMAL = "\27[01;0m"

-- LuaFormatter off
local modes = {
  {name = "trace"    , color = GRAY       , }                   ,
  {name = "debug"    , color = GRAY       , }                   ,
  {name = "progress" , color = BLUE       , display_name = "  > "} ,
  {name = "info"     , color = GREEN      , }                   ,
  {name = "warn"     , color = DARKYELLOW , }                   ,
  {name = "error"    , color = RED        , }                   ,
  {name = "fatal"    , color = RED        , }
}
-- LuaFormatter on

local levels = {}
for i, v in ipairs(modes) do levels[v.name] = i end

local _tostring = tostring

local tostring = function(...)
  local t = {}
  for i = 1, select('#', ...) do
    local x = select(i, ...)
    t[#t + 1] = _tostring(x)
  end
  return table.concat(t, " ")
end

-- Output to log file
local fp
if log.outfile then fp = io.open(log.outfile, "a") end

for i, x in ipairs(modes) do
  local nameupper = x.display_name or x.name:upper()
  log[x.name] = function(...)

    -- Return early if we're below the log level
    if i < levels[log.level] then return end

    local msg = tostring(...)
    local info = debug.getinfo(2, "Sl")
    local lineinfo = string.format("%s:%d", info.short_src, info.currentline)

    -- Output to console
    stderr:write(string.format("%s[%-5s] %s %s\t%s\n",
                               log.usecolor and x.color or "", nameupper,
                               log.usecolor and NORMAL or "", lineinfo, msg))

    if fp then
      local str = string.format("[%-6s%s] %s: %s\n", nameupper, os.date(),
                                lineinfo, msg)
      fp:write(str)
    end

  end
end

return log
