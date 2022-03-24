--- A module for combinatorics.
--
-- @module aoc.combinatorics
-- @alias M
local M = {}

--- Generate all possible permutations of n objects. Objects are permutated in-place.
-- This is an implementation of Heap's algorithm using coroutines.
--
-- @param objects the objects to be permutated
--
-- @usage
-- local t = {1, 2, 3}
-- for perm in combinatorics.permutations(t) do
-- ...
-- end
M.permutations = function(objects)
  local function swap(i, j)
    -- swap elements, but i and j are zero-based; account for Lua's quirks here
    i = i + 1
    j = j + 1
    local old = objects[i]
    objects[i] = objects[j]
    objects[j] = old
  end

  return coroutine.wrap(function()
    local n = #objects
    -- c is an encoding of the stack state. c[k] encodes the for-loop counter for when generate(k - 1, A) is called
    local c = {}
    for i = 0, n - 1 do c[i] = 0 end

    if n == 0 then return nil end

    coroutine.yield(objects)

    local i = 0
    while i < n do
      if c[i] < i then
        if i % 2 == 0 then
          swap(0, i)
        else
          swap(c[i], i)
        end
        coroutine.yield(objects)
        -- Swap has occurred ending the for-loop. Simulate the increment of the for-loop counter
        c[i] = c[i] + 1
        -- Simulate recursive call reaching the base case by bringing the pointer to the base case analog in the array
        i = 0
      else
        -- Calling generate(i+1, A) has ended as the for-loop terminated. Reset the state and simulate popping the stack by incrementing the pointer.
        c[i] = 0
        i = i + 1
      end
    end
  end)
end

return M
