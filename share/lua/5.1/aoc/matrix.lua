local M = {}

local floor = math.floor

-- Rotate a matrix by 90 degrees counter-clockwise.
M.rotate = function(mat)
  local N = #mat + 1
  local upper = floor(N / 2)
  for x = 1, upper do
    -- Consider elements in group of 4 in current square
    for y = x, N - 1 - x do
      -- Store current cell in temp variable
      local temp = mat[x][y];

      -- Move values from right to top
      mat[x][y] = mat[y][N - x]

      -- Move values from bottom to right
      mat[y][N - x] = mat[N - x][N - y]

      -- Move values from left to bottom
      mat[N - x][N - y] = mat[N - y][x]

      -- Assign temp to left
      mat[N - y][x] = temp;
    end
  end
end

M.flip = function(mat)
  local N = #mat
  for i = 1, floor(N / 2) do
    -- swap i and N-i+1
    local temp = mat[i]
    mat[i] = mat[N - i + 1]
    mat[N - i + 1] = temp
  end
end

return M
