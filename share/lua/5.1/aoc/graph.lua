--- A module for graph theory.
--
-- @module aoc.graph
-- @alias M
local M = {}

local min = math.min

--- `bfs` performs a breadth-first search on the underlying graph.
--
--  @param self an instance of graph
--  @int s source node
--  @int t target node
--  @tab parent a table which stores the path from s to t
--  @return true if there is a path from source 's' to sink 't'
local function bfs(self, s, t, parent)
  local queue = {}
  table.insert(queue, s)

  local visited = {}
  visited[s] = true

  local adj = self.adj
  -- Standard BFS Loop
  while queue[1] ~= nil do
    -- Dequeue a vertex from queue
    local u = table.remove(queue, 1)

    -- Get all adjacent vertices of the dequeued vertex u
    -- If a adjacent has not been visited, then mark it
    -- visited and enqueue it
    for ind, val in ipairs(adj[u]) do
      -- notice: we only take the path if val > 0
      if not visited[ind] and val > 0 then
        table.insert(queue, ind)
        visited[ind] = true
        parent[ind] = u
      end
    end
  end

  -- If we reached sink in BFS starting from source, then return
  --  true, else false
  return visited[t] == true
end

--- `max_flow` computes the maximum flow in a flow network using the Ford–Fulkerson method.
-- This is an implementation of the [Edmonds-Karp Algorithm](https://en.wikipedia.org/wiki/Edmonds%E2%80%93Karp_algorithm).
-- The idea of Edmonds-Karp is to use BFS in Ford Fulkerson implementation as
-- BFS always picks a path with minimum number of edges. When BFS is used, the
-- worst case time complexity can be reduced to `O(VE^2)`. The below
-- implementation uses adjacency matrix representation though where BFS takes
-- `O(V^2)` time, **the time complexity of the above implementation** is `O(EV^3)`.
--
-- Based on [geeksforgeeks.org/ford-fulkerson-algorithm-for-maximum-flow-problem/](https://www.geeksforgeeks.org/ford-fulkerson-algorithm-for-maximum-flow-problem/).
--
-- @param self an instance of graph; the capacity of an edge is stored in the adj. matrix
-- @int source the source node
-- @int sink the sink node
-- @return the maximum flow from `source` to `sink` in the given graph
-- @return the residual graph: `r(u,v) = c(u,v) - f(u,v)`
--
-- @usage
-- local source, sink = 1, 6
-- local max_flow, residual_graph = g:max_flow(source, sink)
local function max_flow(self, source, sink)
  -- This array is filled by BFS and to store path
  local parent = {}
  for _ = 1, self.row_count do table.insert(parent, -1) end

  -- the maximum flow in this graph; no flow initially
  local result = 0

  local adj = {}
  local selfadj = self.adj
  for i = 1, self.row_count do
    adj[i] = {}
    for j = 1, self.col_count do adj[i][j] = selfadj[i][j] end
  end
  local g = M.new(adj)

  -- Augment the flow while there is path from source to sink
  while g:bfs(source, sink, parent) do
    -- Find minimum residual capacity of the edges along the
    -- path filled by BFS. Or we can say find the maximum flow
    -- through the path found.
    local path_flow = math.huge
    local s = sink
    while s ~= source do
      path_flow = min(path_flow, adj[parent[s]][s])
      s = parent[s]
    end

    -- Add path flow to overall flow
    result = result + path_flow

    -- update residual capacities of the edges and reverse edges
    -- along the path
    local v = sink
    while v ~= source do
      local u = parent[v]
      adj[u][v] = adj[u][v] - path_flow
      adj[v][u] = adj[v][u] + path_flow
      v = parent[v]
    end
  end

  -- remove reverse edges from residual graph
  for i = 1, self.row_count do
    for j = 1, self.col_count do if selfadj[i][j] == 0 then adj[i][j] = 0 end end
  end

  return result, adj
end

--- Create a `.dot` file for the underlying graph.
--
-- This can be converted to some other format, e.g. `dot -Tpng g.dot -o g.png`.
-- @string fname
-- @tab node_names
local function dotfile(self, fname, node_names)
  local adj = self.adj
  local f = io.open(fname, "w")
  f:write("digraph G {\n")
  for i = 1, self.row_count do
    local t = adj[i]
    for j = 1, self.col_count do
      if t[j] > 0 then
        f:write(string.format("%s -> %s [ label = \"%d\" ];\n",
                              node_names[i] or i, node_names[j] or j, t[j]))
      end
    end
  end

  f:write("\n}")
  f:close()
end

--- Create a new directed graph using adjacency matrix representation.
--
--  `adj[i][j] = 16` means there is an edge from `i` to `j` with capacity 16.
--
-- @tab adj the adjacency matrix of the graph
-- @usage
-- local adj = {
--   {0, 16, 13, 0, 0, 0},
--   {0, 0, 10, 12, 0, 0},
--   {0, 4, 0, 0, 14, 0},
--   {0, 0, 9, 0, 0, 20},
--   {0, 0, 0, 7, 0, 4},
--   {0, 0, 0, 0, 0, 0}
-- }
-- local g = new(adj)
local function new(adj)
  return {
    adj = adj,
    row_count = #adj,
    col_count = #adj[1],
    bfs = bfs,
    max_flow = max_flow,
    dotfile = dotfile
  }
end
M.new = new

return M
