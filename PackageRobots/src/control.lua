
local init = function()
  if not global.land_logistic then global.land_logistic = {} end
end

local check_tables = function()
  local ll = global.land_logistic
  if not ll.drops        then ll.drops        = {} end -- unload positions
  if not ll.pickups      then ll.pickups      = {} end -- load positions
  if not ll.junctions    then ll.junctions    = {} end -- all junction tiles
  if not ll.tiles        then ll.tiles        = {} end -- all direction tiles
  if not ll.robots       then ll.robots       = {} end -- list of robots
  if not ll.paths        then ll.paths        = {} end -- pre-calculated paths
  if not ll.sleepers     then ll.sleepers     = {} end -- pre-calculated paths
  if not ll.queues       then ll.queues       = {} end -- queue stack points
end

local get_net = function(robot)
  local x = round(robot.entity.position.x)
  local y = round(robot.entity.position.y)
  return global.land_logistic.tiles[x][y];
end

local check_path = function(surface, pickup, drop)
  local path = global.land_logistic.paths[pickup.id][drop.id]
  if path then
    for _,tile_entry in pairs(path) do
      local tile = surface.get_tile(tile_entry.x, tile_entry.y)
      if not string.find(tile.name, tile_entry.dir) then 
        return false
      end
    end
    return true
  else
    return false
  end
end

--[[ to= ]]
local calculate_path_limited = function(surface, from, to, limit)
  local path = nil
  local QUEUE = {}
  local qstart = 0
  local qend = 0
  
  pickup.CALC = 0
  pickup.PREV = -1
  --PATH CALCULATOR
  QUEUE[start] = from
  while QUEUE[start] do
    --POP START
    local cur = QUEUE[start]
    QUEUE[start] = nil
    qstart = qstart + 1
    --POP END
    
    --CHECK SIDES
    local x = cur.x
    local y = cur.y
    
  end
  
  return path
end

local calculate_path = function(surface, from, to)
  return calculate_path_limited(surface, from, to, -1)
end

local search_job = function(robot) 
  -- SEARCHING FOR DROP
  local found_drop = false
  for _,drop in pairs(global.land_logistic.drops) do
    -- SEARCHING FOR PICKUP
    local found_pickup = false
    for _,pickup in pairs(global.land_logistic.pickups) do
      if drop.res == pickup.res then
        if check_path(robor.entity.surface, pickup, drop) then
          robot.path = calculate_path(robor.entity.surface, robot.tile, drop)
          robot.state = 1 --[[RUN_FICKUP]]
          drop.served = true
          pickup.server = true
          return
        else
          global.land_logistic.paths[pickup.id][drop.id] =
            calculate_path(robor.entity.surface, pickup, drop)
        end
      end
    end
  end
end

local move_robot = function(robot)
  
end

local on_tick = function(event)
  check_tables()
--  game.print(global.land_logistic.robots.count or 0)
  
  for _, robot in pairs(global.land_logistic.robots) do
    if robot.net then
      if robot.state == 0 --[[IDDLE]] then
        search_job(robot)
      else
        move_robot()
      end
    else
      get_net(robot)
    end
  end
end

local on_built_tile = function(event)
  local tiles = event.tiles
end

local on_mined_tile = function(event)
  local tiles = event.tiles
end

local on_built_entity = function(event)
  local entity = event.created_entity
  
  if entity and entity.name == "land-robot" then
    global.land_logistic.robots[entity.unit_number] = {
      id = entity.unit_number,
      state = 0 --[[IDDLE]],
      entity = entity,
      tile = get_net(entity.position)
    }
    global.land_logistic.robots.count = (global.land_logistic.robots.count or 0) + 1
  end
end

local on_mined_entity = function(event)
  local entity = event.entity
  
  if entity and entity.name == "land-robot" and global.land_logistic.robots[entity.unit_number] then
    global.land_logistic.robots[entity.unit_number] = nil
    global.land_logistic.robots.count = global.land_logistic.robots.count - 1
  end
end

script.on_init(init)
script.on_load(init)
script.on_event(defines.events.on_tick, on_tick)
script.on_event(defines.events.on_player_built_tile, on_built_tile)
script.on_event(defines.events.on_player_mined_tile, on_mined_tile)
script.on_event(defines.events.on_built_entity, on_built_entity)
script.on_event(defines.events.on_player_mined_entity, on_mined_entity)