[![CI](https://github.com/michaeladler/aoc-2020/actions/workflows/ci.yml/badge.svg)](https://github.com/michaeladler/aoc-2020/actions/workflows/ci.yml)

# AoC 2020

My second [Advent of Code](https://adventofcode.com/2020) event.
This year I used [LuaJIT](https://luajit.org/).

## Lessons Learned

* LuaJIT is amazingly fast (the fastest scripting language as of 2020)
* [luaprompt](https://github.com/dpapavas/luaprompt) is great for rapid prototyping
* Lack of 64-bit integers in LuaJIT can be a problem
  **Workarounds**:
    * use a shared library (e.g. written in C) and use LuaJIT's awesome FFI.
    * use Lua 5.4 which is quite fast too
* It is rather annoying that tables cannot be used as keys in other tables; use hacks like `string.format` to serialize the table and use it as a key
* Lua's default behavior to return `nil` instead of an out-of-bounds error for accessing non-existing table keys is *great*
* [Penlight's](http://stevedonovan.github.io/Penlight/api/index.html) most useful feature was the `__tostring` implementations for tables (which helped a lot in the REPL)

