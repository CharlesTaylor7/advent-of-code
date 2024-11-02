local function get_input()
  local file = arg[0]
  for dir in file:gmatch("(.*)/") do
    local filename = dir .. "/input.txt"
    local file = io.open(filename)
    if file == nil then
      error()
    end
    local contents = file:read("*a")
    file:close()
    return contents
  end
end

local function parse(input)
  return coroutine.wrap(function()
    local lines = (input .. "\n"):gmatch("([^\n]+)\n")
    for line in lines do
      local row = {}
      for action, x1, y1, x2, y2 in line:gmatch("([%a%s]+)(%d+),(%d+) through (%d+),(%d+)") do
        coroutine.yield({
          action = action,
          x1 = tonumber(x1),
          x2 = tonumber(x2),
          y1 = tonumber(y1),
          y2 = tonumber(y2),
        })
      end
    end
  end)
end
local function part1()
  -- local input = "turn on 1,3 through 4,5"
  local lights = {}
  for row in parse(get_input()) do
    for x = row.x1, row.x2 do
      for y = row.y1, row.y2 do
        local key = x .. "," .. y
        if row.action == "turn off " then
          lights[key] = false
        elseif row.action == "turn on " then
          lights[key] = true
        elseif row.action == "toggle " then
          lights[key] = not lights[key]
        else
          error()
        end
      end
    end
  end

  local tally = 0
  for _, value in pairs(lights) do
    if value then
      tally = tally + 1
    end
  end
  return tally
end

local function part2()
  local lights = {}
  for row in parse(get_input()) do
    for x = row.x1, row.x2 do
      for y = row.y1, row.y2 do
        local key = x .. "," .. y
        local value = lights[key] or 0
        if row.action == "turn off " then
          lights[key] = math.max(value - 1, 0)
        elseif row.action == "turn on " then
          lights[key] = value + 1
        elseif row.action == "toggle " then
          lights[key] = value + 2
        else
          error()
        end
      end
    end
  end

  local tally = 0
  for _, value in pairs(lights) do
    tally = tally + value
  end
  return tally
end
print(part2())
