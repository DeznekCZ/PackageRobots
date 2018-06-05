
require ("control.queue")

--[[
--NET DATA 
  drops        - unload positions
  pickups      - load positions
  platforms    - platforms
  flags        - list of flags
  filters      - list of stand flags
  resting      - list of resting points
  tiles        - all direction tiles
--PATH DATA
  paths        - pre-calculated paths
  paths_w      - forbidden paths
--ROBOTS DATA
  robots       - list of robots
]]

PathFinder = {}
PathFinder.__index = PathFinder

setmetatable(PathFinder, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function PathFinder.new(data)
  local self = setmetatable({}, PathFinder)
  
  self.data = data
  self.queue = Queue.new()
  self.registration = {}
  self.per_tick = 5
  --self.debud for change see line 55
  
  return self
end

function PathFinder:log_actions(text)
  game.write_file("land_logistic.log", text .. "\n", true)
end

--[[ the : syntax here causes a "self" arg to be implicitly added before any other args
function MyClass:set_value(newval)
  self.value = newval
end]]
--[[
function MyClass:get_value()
  return self.value
end]]

function PathFinder.DEBUG(self, tile_x)
--[[] -- give here a bracket for see debug mode
  game.players[1].character.surface.create_entity{
        name = "wooden-chest", 
        position = tile_x,
        force = game.players[1].force
      }
--[[]]
end

function PathFinder.QID(self, value)
  return value.x .. "_" .. value.y
end

function PathFinder.TILE(self, x, y)
  local x_path = self.data.tiles[x]
  if x_path then 
    return x_path[y]
  else 
    return nil
  end
end

 --[[ tile_x not nil ]]
function PathFinder.SUM(self, tile_a, tile_b)
  return { x = tile_a.x + tile_b.x, y = tile_a.y + tile_b.y }
end

 --[[ tile_x not nil ]]
function PathFinder.DIFF(self, tile_a, tile_b)
  return { x = tile_a.x - tile_b.x, y = tile_a.y - tile_b.y }
end

 --[[ tile_x not nil ]]
function PathFinder.MULTIPLE_EACH(self, tile_a, tile_b)
  return { x = tile_a.x * tile_b.x, y = tile_a.y * tile_b.y }
end

 --[[ tile_x not nil ]]
function PathFinder.DIST(self, tile_x)
  local diff_a = PathFinder.DIFF(self, self.last.from, tile_x)
  local diff_b = PathFinder.DIFF(self, self.last.to,   tile_x)
  local mult_a = PathFinder.MULTIPLE_EACH(self, diff_a, diff_a)
  local mult_b = PathFinder.MULTIPLE_EACH(self, diff_b, diff_b)
  local sum    = PathFinder.SUM(self, mult_a, mult_b)
  return (sum.x) + (sum.y)
end

function PathFinder.TILE_P(self, position)
  local x_path = self.data.tiles[position.x]
  if x_path then 
    return x_path[position.y]
  else 
    return nil
  end
end

function PathFinder.set_path(self, start_pos, end_pos, path)
  local starts = self.data.paths[start_pos.id]
  if not starts then
    self.data.paths[start_pos.id] = { [end_pos.id] = path }
  else
    starts[end_pos.id] = path
  end
end

function PathFinder:register(surface, from, to, tries)
  if (not surface) or (not from) or (not to) then
    return nil
  end

  local w_path_id = from.x .. "_" .. from.y .. "-" .. to.x .. "_" .. to.y
  local do_calculation = false
  
  local reg = self.registration[w_path_id]
  if reg and reg.calculated then
    path.path = reg.path
  elseif reg then
    path.invalid = true
    path.tries = reg.tries
    PathFinder.log_actions(self, "Path [" .. w_path_id .. "] is in queue")
  else
    do_calculation = true
  end
  
  if path.path then
    --log_actions("checking path: " .. start_pos.x .. ":" .. start_pos.y .. " " .. end_pos.x .. ":" .. end_pos.y)
    for _,tile_entry in pairs(path.path) do
      local tile = surface.get_tile(tile_entry.x, tile_entry.y)
      if not tile.name:gmatch(".*" .. tile_entry.dir) then 
        path.path = nil
        do_calculation = true
        break
      end
    end
  end
  
  if do_calculation then
    path.invalid = true
    reg = {
      calculated = false,
      surface = surface,
      from = from,
      to = to,
      id = w_path_id,
      tries_limit = tries
    }
    self.registration[w_path_id] = reg
    self.queue:push(reg)
    PathFinder.log_actions(self, "Path [" .. w_path_id .. "] registered")
  end
  
  if tries and tries == reg.tries then self.registration[w_path_id] = nil end
  return path
end

function PathFinder.ENQUEUE(self, cur, queue, visited, x, y)
  --PathFinder.log_actions(self, serpent.block(cur))
  local NT = PathFinder.TILE(self, x, y)
  if NT then
    if NT.cross then -- SKIP cross
      PathFinder.DEBUG(self, NT)
      local cross_idx  = 2
      local cross_tile = PathFinder.TILE(self, cross_idx * (x - cur.x) + cur.x, cross_idx * (y - cur.y) + cur.y)
      local cross_path = Queue.new(NT)
      while cross_tile and cross_tile.cross do
        PathFinder.DEBUG(self, cross_tile)
        cross_path:push(cross_tile)
        cross_idx = cross_idx + 1
        cross_tile = PathFinder.TILE(self, cross_idx * (x - cur.x) + cur.x, cross_idx * (y - cur.y) + cur.y)
      end
      if cross_tile then
        local vqid = PathFinder.QID(self, cross_tile)
        if not visited[vqid] then 
          visited[vqid] = { source = cur, source_id = PathFinder.QID(self, cur), crossed = cross_path }
          queue:push(cross_tile, self:DIST(cross_tile))
        end
      end
    else
      local vqid = PathFinder.QID(self, NT)
      if not visited[vqid] then 
        visited[vqid] = { source = cur, source_id = PathFinder.QID(self, cur) }
        queue:push(NT, self:DIST(NT))
      end
    end
  end
end

--[[ 
  Method evaluates current Path_Tile_X
  
  Arguments:
  C_ID    - QID(CUR)
  CUR     - current Tile_X
  QUEUE   - instance of Queue
  VISITED - table of QID(*) values
]]
function PathFinder.EVL_PATH(self, cur, queue, visited)
  PathFinder.EVL_PLAT(self, cur, queue, visited) -- mark all platforms visited
  
  if     cur.dir == "path-n" then
    PathFinder.ENQUEUE(self, cur, queue, visited, cur.x, cur.y - 1)
  elseif cur.dir == "path-e" then
    PathFinder.ENQUEUE(self, cur, queue, visited, cur.x + 1, cur.y)
  elseif cur.dir == "path-s" then
    PathFinder.ENQUEUE(self, cur, queue, visited, cur.x, cur.y + 1)
  elseif cur.dir == "path-w" then
    PathFinder.ENQUEUE(self, cur, queue, visited, cur.x - 1, cur.y)
  end
end

--[[ 
  Method evaluates current Junction_Tile_X
  
  Arguments:
  C_ID    - QID(CUR)
  CUR     - current Tile_X
  QUEUE   - instance of Queue
  VISITED - table of QID(*) values
]]
function PathFinder.EVL_JUNC(self, cur, queue, visited)
  PathFinder.EVL_PLAT(self, cur, queue, visited) -- mark all platforms visited
  
  PathFinder.ENQUEUE(self, cur, queue, visited, cur.x, cur.y - 1)
  PathFinder.ENQUEUE(self, cur, queue, visited, cur.x + 1, cur.y)
  PathFinder.ENQUEUE(self, cur, queue, visited, cur.x, cur.y + 1)
  PathFinder.ENQUEUE(self, cur, queue, visited, cur.x - 1, cur.y)
end

--[[ 
  Method evaluates current Pickup_Tile_X, Drop_Tile_X or Restbox_Tile_X
  
  Arguments:
  C_ID    - QID(CUR)
  CUR     - current Tile_X
  QUEUE   - instance of Queue
  VISITED - table of QID(*) values
]]
function PathFinder.EVL_SPEC(self, cur, queue, visited)
  local EN = PathFinder.TILE(self, cur.x, cur.y - 1) --NORTH
  if EN and (EN.path or EN.junction) then PathFinder.ENQUEUE(self, cur, queue, visited, cur.x, cur.y - 1) end
  local EE = PathFinder.TILE(self, cur.x + 1, cur.y) --EAST
  if EE and (EE.path or EE.junction) then PathFinder.ENQUEUE(self, cur, queue, visited, cur.x + 1, cur.y) end
  local ES = PathFinder.TILE(self, cur.x, cur.y + 1) --SOUTH
  if ES and (ES.path or ES.junction) then PathFinder.ENQUEUE(self, cur, queue, visited, cur.x, cur.y + 1) end
  local EW = PathFinder.TILE(self, cur.x - 1, cur.y) --WEST
  if EW and (EW.path or EW.junction) then PathFinder.ENQUEUE(self, cur, queue, visited, cur.x - 1, cur.y) end
end

--[[ 
  Method evaluates current Junction_Tile_X or Path_Tile_X
  
  Arguments:
  C_ID    - QID(CUR)
  CUR     - current Tile_X
  QUEUE   - instance of Queue
  VISITED - table of QID(*) values
]]
function PathFinder.EVL_PLAT(self, cur, queue, visited)
  local EN = PathFinder.TILE(self, cur.x, cur.y - 1) --NORTH
  if EN and (EN.pickup or EN.drop or EN.resting) then PathFinder.ENQUEUE(self, cur, queue, visited, cur.x, cur.y - 1) end
  local EE = PathFinder.TILE(self, cur.x + 1, cur.y) --EAST
  if EE and (EE.pickup or EE.drop or EE.resting) then PathFinder.ENQUEUE(self, cur, queue, visited, cur.x + 1, cur.y) end
  local ES = PathFinder.TILE(self, cur.x, cur.y + 1) --SOUTH
  if ES and (ES.pickup or ES.drop or ES.resting) then PathFinder.ENQUEUE(self, cur, queue, visited, cur.x, cur.y + 1) end
  local EW = PathFinder.TILE(self, cur.x - 1, cur.y) --WEST
  if EW and (EW.pickup or EW.drop or EW.resting) then PathFinder.ENQUEUE(self, cur, queue, visited, cur.x - 1, cur.y) end
end

--[[ 
  Method evaluates current Tile_X
  
  Arguments:
  C_ID    - QID(CUR)
  CUR     - current Tile_X
  QUEUE   - instance of Queue
  VISITED - table of QID(*) values
]]
function PathFinder.EVL(self, cur, queue, visited)
  --PathFinder.log_actions(self, "[X:"..cur.x..";Y="...cury.."]="..serpent.block(cur))
  --PathFinder.log_actions(self, serpent.block(cur))
  if     cur.path                              then PathFinder.EVL_PATH(self, cur, queue, visited)
  elseif cur.junction or cur.cross             then PathFinder.EVL_JUNC(self, cur, queue, visited)
  elseif cur.pickup or cur.drop or cur.resting then PathFinder.EVL_SPEC(self, cur, queue, visited)
  end
end

--[[  ]]
function PathFinder.STEP(self, count, queue, visited, s_id, e_id, reg)
  local step = count
  while step > 0 and (not queue:is_empty()) do
    --PathFinder.log_actions(self, serpent.block(queue))
    local cur = queue:pop()
    local cqid = PathFinder.QID(self, cur)
    
    PathFinder.DEBUG(self, cur)
    
    if cqid == e_id then
      return true
    end
    
    PathFinder.EVL(self, cur, queue, visited)
    
    step = step - 1 -- NEXT COUNTING
  end
  
  return false
end

function PathFinder.COPY_PATH(self, reg)
  local path_flipped = {}
  local idx = 1
  local pqid = reg.eqid
  local last = reg.to
  local visited = reg.visited
  
  while pqid ~= reg.fqid do
    local vcur = visited[pqid]
    local crossed = vcur.crossed
    if crossed then
      while not crossed:is_empty() do
        local cross_tile = crossed:pop()
        path_flipped[idx] = {
          x = cross_tile.x,
          y = cross_tile.y,
          dir = cross_tile.dir
        }
        idx = idx + 1
      end
    end
    
    path_flipped[idx] = {
      x = last.x,
      y = last.y,
      dir = last.dir
    }
    pqid = vcur.source_id
    last = vcur.source
    idx = idx + 1
  end
  path_flipped[idx] = {
    x = reg.from.x,
    y = reg.from.y,
    dir = reg.from.dir
  } 
  local path = {}
  local diversion = #path_flipped + 1
  for i,v in pairs(path_flipped) do
    path[diversion - i] = v
  end
  reg.path = path
  PathFinder.set_path(self, self:TILE_P(reg.from), self:TILE_P(reg.to), path)
end

function PathFinder:tick()
  local last = self.last
  if not last then
    if self.queue:is_empty() then
      return
    else
      self.last = self.queue:pop()
      last = self.last
      last.queue = Queue.new(PathFinder.TILE(self, last.from.x, last.from.y))
      last.visited = {[PathFinder.QID(self, last.from)] = {}}
      last.fqid = last.fqid or PathFinder.QID(self, last.from)
      last.eqid = last.eqid or PathFinder.QID(self, last.to)
      PathFinder.log_actions(self, "Path [" .. last.id .. "] search start")
    end
  end
  -- PATH FOUND IN LAST SESSION
  if last.path_found then 
    PathFinder.COPY_PATH(self, last)
    PathFinder.log_actions(self, "Path [" .. last.id .. "] found")
    self.last = nil
    last.repeated = nil
    last.surface = nil
    last.queue = nil
    last.visited = nil
    last.fqid = nil
    last.eqid = nil
    last.path_found = nil
    last.tries = 1 + (last.tries or 0)
    last.calculated = true
  -- QUEUE IS EMPTY
  elseif last.queue:is_empty() then
    PathFinder.log_actions(self, "Path [" .. last.id .. "] not found")
    self.last = nil
    last.repeated = nil
    last.queue = nil
    last.visited = nil
    last.path_found = nil
    last.tries = 1 + (last.tries or 0)
    if last.tries_limit 
    and last.tries_limit < last.tries then
      self.queue:push(last)
    end
  -- STEP SESSION
  else                    
    last.path_found = PathFinder.STEP(self, 
      self.per_tick, -- COUNT GIVEN LATER BY CONFIG
      last.queue,
      last.visited,
      last.fqid,
      last.eqid,
      last
    )
  end
end