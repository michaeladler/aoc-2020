local M = {}

local ffi = require 'ffi'
ffi.cdef [[
  int64_t aoc_nt_modinv(int64_t a, int64_t m);
  int64_t aoc_nt_chinese_remainder(int64_t num[], int64_t rem[], int k);
]]

local libaoc = ffi.load("aoc")

--- number x such that:
-- x % num[0] = rem[0],
-- x % num[1] = rem[1],
-- ..................
-- x % num[k-2] = rem[k-1]
-- Assumption: Numbers in num[] are pairwise coprime
-- (gcd for every pair is 1)
local function chinese_remainder(num, rem)
  -- assert(#num == #rem)
  local n = #num
  local c_num = ffi.new("int64_t[?]", n)
  for i = 1, n do c_num[i - 1] = num[i] end
  local c_rem = ffi.new("int64_t[?]", n)
  for i = 1, n do c_rem[i - 1] = rem[i] end
  return libaoc.aoc_nt_chinese_remainder(c_num, c_rem, n)
end
M.chinese_remainder = chinese_remainder

return M
