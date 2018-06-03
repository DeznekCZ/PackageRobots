
local init = function()
  if not global.land_logistic then global.land_logistic = {} end
end

local check_tables = function()
  local ll = global.land_logistic
--NET DATA 
  if not ll.drops        then ll.drops        = {} end -- unload positions
  if not ll.pickups      then ll.pickups      = {} end -- load positions
  if not ll.platforms    then ll.platforms    = {} end -- platforms
  if not ll.flags        then ll.flags        = {} end -- list of flags
  if not ll.tiles        then ll.tiles        = {} end -- all direction tiles
--PATH DATA
  if not ll.paths        then ll.paths        = {} end -- pre-calculated paths
--ROBOTS DATA
  if not ll.robots       then ll.robots       = {} end -- list of robots
end

local function is_platform(tile_x)
  if tile_x and tile_x.platform then return tile_x else return nil end
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


local function detach_platform(tile_x, platform)
  platform.tiles[tile_x.id] = nil
  if #platform.tiles == 0 then
    global.land_logistic.platforms[platform.id] = nil
  end
end

local function attach_platform(from, to)
  local platform = global.land_logistic.platforms[to.id]
  
  if from.platform_id ~= to.platform_id then
    local from_platform = global.land_logistic.platforms[from.id]
    global.land_logistic.platforms[from.id] = nil -- remove last platform
    
    for _,tile in pairs(from_platform.tiles) do
      platform.tiles[tile.id] = tile
      tile.platform_id = platform.id
    end
  end
end

local function connect_platform(platform_tile, new_tile)
  if not platform_tile then return end
  
  if new_tile.platform_id ~= -1 then
    attach_platform(platform_tile, new_tile)
  elseif platform_tile then
    new_tile.platform_id = platform_tile.platform_id
    local platform = global.land_logistic.platforms[new_tile.platform_id]
    platform.tiles[new_tile.id] = global.land_logistic.tiles[new_tile.x][new_tile.y]
  end
end

local function init_tile(tile_x)
  local dir = tile_x.dir
  
  tile_x.platform = (tile_x.dir == "path-d") or (tile_x.dir == "path-p") or (tile_x.dir == "path-l")
  tile_x.drop = (tile_x.dir == "path-d")
  tile_x.pickup = (tile_x.dir == "path-p")
  tile_x.flag = (tile_x.dir == "path-l")
  tile_x.junction = (tile_x.dir == "path-j")
  tile_x.cross = (tile_x.dir == "path-x")
  tile_x.path = (tile_x.dir == "path-n") or (tile_x.dir == "path-e") or (tile_x.dir == "path-s") or (tile_x.dir == "path-w")
  
--  game.print{"pp-path.type", 
--             tile_x.platform, tile_x.drop, tile_x.pickup, tile_x.flag, 
--             tile_x.junction, tile_x.cross, tile_x.path}
  
  local x = tile_x.x
  local y = tile_x.y
  local id = tile_x.id
  local tn = get_tile(x, y - 1)
  local te = get_tile(x + 1, y)
  local ts = get_tile(x, y + 1)
  local tw = get_tile(x - 1, y)
  
  if tile_x.platform then 
    tile_x.platform_id = -1
    
    --PLATFORM exists
    connect_platform(is_platform(tn), tile_x)
    connect_platform(is_platform(te), tile_x)
    connect_platform(is_platform(ts), tile_x)
    connect_platform(is_platform(tw), tile_x)
    if tile_x.platform_id == -1 then
      tile_x.platform_id = tile_x.id
      platform = {
        id = tile_x.platform_id,
        tiles = {
          [tile_x.id] = tile_x
        }
      }
      global.land_logistic.platforms[tile_x.platform_id] = platform
    end
  end
  
  if tile_x.drop then
    global.land_logistic.drops[id] = tile_x
    
    return true
  elseif tile_x.pickup then
    global.land_logistic.pickups[id] = tile_x
    
    return true
  elseif tile_x.flag then
    global.land_logistic.flags[id] = tile_x
    
    return true
  elseif tile_x.junction then
    
    return true
  elseif tile_x.cross then
    
    return true
  elseif tile_x.path then    
    
    return true
  else
    return false
  end
end

local function set_tile(fx, fy, tile)
  local x = math.floor(fx)
  local y = math.floor(fy)
  local x_path = global.land_logistic.tiles[x]
  if not x_path then 
    global.land_logistic.tiles[x] = {}
    x_path = global.land_logistic.tiles[x]
  end
  
  if tile and tile.name:gmatch(".*-path-.") then
    local tile_x = {
      id   = global.land_logistic.tile_id or 0,
      x    = x,
      y    = y,
      name = tile.name,
      dir  = string.gsub(tile.name, ".*-path", "path")
    }
    
    if init_tile(tile_x) then
      x_path[y] = tile_x
      global.land_logistic.tile_id = tile_x.id + 1
    else
      x_path[y] = nil
    end
  elseif x_path[y] then
    local tile_x = x_path[y]
    x_path[y] = nil
    if is_platform(tile_x) then
      detach_platform(tile_x, global.land_logistic.platforms[tile_x.platform_id])
    end
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
  local surface = game.surfaces[event.surface_index]
  local tiles = event.tiles
  for _,tile in pairs(tiles) do
    set_tile(tile.position.x, tile.position.y, surface.get_tile(tile.position.x, tile.position.y))
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
  
  if entity and entity.name == "land-robot" then
    global.land_logistic.robots[entity.unit_number] = nil
  end
end

script.on_init(init)
script.on_load(init)
script.on_event(defines.events.on_tick, on_tick)
script.on_event({defines.events.on_player_built_tile,   defines.events.on_robot_built_tile  }, on_built_tile)
script.on_event({defines.events.on_player_mined_tile,   defines.events.on_robot_mined_entity}, on_mined_tile)
script.on_event({defines.events.on_built_entity,        defines.events.on_robot_built_entity}, on_built_entity)
script.on_event({defines.events.on_player_mined_entity, defines.events.on_robot_mined_tile  }, on_mined_entity)
script.on_event({defines.events.on_console_command}, function(event)
  if event.command == "h" then
    game.print{"", "Printing land_logistic"}
    game.write_file("land_logistic.lua", serpent.block(global.land_logistic) .. "\n", false)
  end
end)
