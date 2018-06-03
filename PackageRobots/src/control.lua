
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

local function get_tile(fx, fy)
  local x = math.floor(fx)
  local y = math.floor(fy)
  local x_path = global.land_logistic.tiles[x]
  if x_path then 
    return x_path[y]
  else 
    return nil
  end
end

local function set_tile(fx, fy, tile)
  local x = math.floor(fx)
  local y = math.floor(fy)
  local x_path = global.land_logistic.tiles[x]
  if not x_path then 
    x_path = {}
    global.land_logistic.tiles[x] = x_path
  end
  
  if tile and tile.name:gmatch(".*-path-.") then
    tile_x = {
      id   = global.land_logistic.tiles.id or 0,
      x    = tile.x,
      y    = tile.y,
      name = tile.name,
      dir  = string.gsub(tile.name, ".*-path", "path")
    }
    game.print(tile_x.dir)
    
    x_path[y] = tile_x
    global.land_logistic.tiles.id = tile_x.id + 1
  elseif x_path[y] then
    x_path[y] = nil
  end
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
          if not global.land_logistic.paths[pickup.id] then
            global.land_logistic.paths[pickup.id] = {} end
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
    if robot.tile then
      if robot.state == 0 --[[IDDLE]] then
        search_job(robot)
      else
        move_robot()
      end
    else
      robot.tile = get_tile(robot.entity.position.x, robot.entity.position.y)
    end
  end
end

local on_built_tile = function(event)
  local tiles = event.tiles
  for _,tile in pairs(tiles) do
    set_tile(tile.position.x, tile.position.y, tile)
  end
end

local function on_mined_tile(event)
  local tiles = event.tiles
  for _,tile in pairs(tiles) do
    set_tile(tile.position.x, tile.position.y, nil)
  end
end

local on_built_entity = function(event)
  local entity = event.created_entity
  
  if not entity then return end
  
  if entity.name == "land-robot" then
    global.land_logistic.robots[entity.unit_number] = {
      id = entity.unit_number,
      state = 0 --[[IDDLE]],
      entity = entity,
      tile = get_tile(entity.position.x, entity.position.y)
    }
    global.land_logistic.robots.count = (global.land_logistic.robots.count or 0) + 1
  elseif entity.name == "resource-flag" then
    local filter = entity.get_filter(1)
    if filter and string.len(filter) > 0 then
      -- game.print({"item-name." .. filter})
      if get_tile(entity.position.x, entity.position.y) then
        game.print("added") -- TODO
      end
    end
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
script.on_event({defines.events.on_player_built_tile,   defines.events.on_robot_built_tile  }, on_built_tile)
script.on_event({defines.events.on_player_mined_tile,   defines.events.on_robot_mined_entity}, on_mined_tile)
script.on_event({defines.events.on_built_entity,        defines.events.on_robot_built_entity}, on_built_entity)
script.on_event({defines.events.on_player_mined_entity, defines.events.on_robot_mined_tile  }, on_mined_entity)

