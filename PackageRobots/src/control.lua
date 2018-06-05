--[[
  PackageRobots - control.lua
  
  Author: Zdenek Novotny (DeznekCZ)
]]
require("control.queue")
require("control.pathfinder")
require("control.robot")

PATH_FINDER = {}

local function reset_log() 
  game.write_file("land_logistic.log", "", false)
end

local function log_actions(text) 
  game.write_file("land_logistic.log", text .. "\n", true)
end

local function export_data() 
  game.write_file("land_logistic.lua", serpent.block(global.land_logistic) .. "\n", false)
end

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
  if not ll.filters      then ll.filters      = {} end -- list of stand flags
  if not ll.resting      then ll.resting      = {} end -- list of resting points
  if not ll.tiles        then ll.tiles        = {} end -- all direction tiles
--PATH DATA
  if not ll.paths        then ll.paths        = {} end -- pre-calculated paths
  if not ll.paths_w      then ll.paths_w      = {} end -- pre-calculated paths
  
  if not ll.path_finder  then
  	ll.path_finder = PathFinder.new(ll)
  	PATH_FINDER = ll.path_finder
  end
end

local function reset_path_calculation()
  global.land_logistic.paths_w = {}
end

local function position(data)
  if data and data.x and data.y and data.id then
    return { x = data.x, y = data.y, id = data.id, dir = data.dir }
  else
    return nil
  end
end

local function is_path(tile)
  if tile and tile.name:gmatch(".*-path-.") then return tile else return nil end
end

local function get_platform(tile_x)
  if tile_x and tile_x.platform then return tile_x else return nil end
end

local function get_platform_by_id(id)
  return global.land_logistic.platforms[id]
end

local function get_tile_round(x, y)
  local x_path = global.land_logistic.tiles[x]
  if x_path then 
    return x_path[y]
  else 
    return nil
  end
end

local function calculate_rest_points(platform)
  --platform.resting:push(rest_id, #path)
end

local function get_tile(fx, fy)
  local x = math.floor(fx)
  local y = math.floor(fy)
  return get_tile_round(x, y)
end

local function detach_platform(tile_x, platform)
  platform.tiles[tile_x.id] = nil
  if #platform.tiles == 0 then
    global.land_logistic.platforms[platform.id] = nil
  end
end

local function attach_platform(from, to)
  local platform = global.land_logistic.platforms[to.platform_id]
  
  if from.platform_id ~= to.platform_id then
    local from_platform = global.land_logistic.platforms[from.platform_id]
    global.land_logistic.platforms[from.id] = nil -- remove last platform
    
    for _,tile_loc in pairs(from_platform.tiles) do
      local tile = global.land_logistic.tiles[tile_loc.x][tile_loc.y]
      platform.tiles[tile.id] = { x = tile_loc.x, y = tile_loc.y, dir = tile_loc.dir }
      tile.platform_id = platform.id
    end
    calculate_rest_points(global.land_logistic.platforms[platform.id])
  end
end

local function connect_platform(platform_tile, new_tile)
  if not platform_tile then return end
  
  if new_tile.platform_id ~= -1 then
    attach_platform(platform_tile, new_tile)
  elseif platform_tile then
    new_tile.platform_id = platform_tile.platform_id
    local platform = global.land_logistic.platforms[new_tile.platform_id]
    platform.tiles[new_tile.id] = { x = new_tile.x, y = new_tile.y, dir = new_tile.dir }
  end
end

local function init_tile(tile_x)
  local dir = tile_x.dir
  
  tile_x.platform = (tile_x.dir == "path-d") or (tile_x.dir == "path-p") or (tile_x.dir == "path-l")
  tile_x.drop = (tile_x.dir == "path-d")
  tile_x.pickup = (tile_x.dir == "path-p")
  tile_x.resting = (tile_x.dir == "path-r")
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
  
  local platform
  if tile_x.platform then 
    tile_x.platform_id = -1
    
    --PLATFORM exists
    connect_platform(get_platform(tn), tile_x)
    connect_platform(get_platform(te), tile_x)
    connect_platform(get_platform(ts), tile_x)
    connect_platform(get_platform(tw), tile_x)
    if tile_x.platform_id == -1 then
      tile_x.platform_id = tile_x.id
      platform = {
        id = tile_x.platform_id,
        tiles = {
          [tile_x.id] = { x = tile_x.x, y = tile_x.y, dir = tile_x.dir }
        },
        resting = Queue.new()
      }
      calculate_rest_points(platform)
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
  elseif tile_x.resting then    
    global.land_logistic.resting[id] = tile_x
    calculate_rest_points(platform)
    return true
  elseif tile_x.junction then
    
    return true
  elseif tile_x.cross then
    
    return true
  elseif tile_x.path then    
    
    return true
  elseif tile_x.resting then    
    for _, platform in pairs(global.land_logistic.platforms) do
      calculate_rest_points(platform)
    end
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
  
  if tile and is_path(tile) then
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
    if get_platform(tile_x) then
      detach_platform(tile_x, global.land_logistic.platforms[tile_x.platform_id])
    end
  end
end

local function get_path(start_pos, end_pos)
  local starts = global.land_logistic.paths[start_pos.id]
  if not starts then return nil end
  local path = starts[end_pos.id]
  return path
end

local function set_path(start_pos, end_pos, path)
  local starts = global.land_logistic.paths[start_pos.id]
  if not starts then
    global.land_logistic.paths[start_pos.id] = { [end_pos.id] = path }
  else
    starts[end_pos.id] = path
  end
end

local function check_filters()
  for _, flag in pairs(global.land_logistic.filters) do
    if flag then
      local tile_x = get_tile(flag.position.x, flag.position.y)
      local platform = global.land_logistic.platforms[tile_x.platform_id]
      platform.res = flag.get_filter(1)
    end
  end
end

local on_tick = function(event)
  check_tables()
  check_filters()
  
  PATH_FINDER:tick()
  
  Robot.tick(event.tick)
end

local on_built_tile = function(event)
  check_tables()
  local surface
  if event.player_index then surface = game.players[event.player_index].surface end
  if event.robot then surface = event.robot.surface end
  
  local tiles = event.tiles
  for _,tile in pairs(tiles) do
    set_tile(tile.position.x, tile.position.y, surface.get_tile(tile.position.x, tile.position.y))
  end
end

local function on_mined_tile(event)
  check_tables()
  local tiles = event.tiles
  for _,tile in pairs(tiles) do
    set_tile(tile.position.x, tile.position.y, nil)
  end
end

local on_built_entity = function(event)
  check_tables()
  local entity = event.created_entity
  
  if not entity then return end
  
  if entity.name == "land-robot" then
    Robot.create(entity)
  elseif entity.name == "resource-flag" then
    global.land_logistic.filters[entity.unit_number] = entity
  
    local filter = entity.get_filter(1)
    if filter and string.len(filter) > 0 then
      -- game.print({"item-name." .. filter})
      local flag_tile = get_tile(entity.position.x, entity.position.y)
      if flag_tile then
        local platform = get_platform_by_id(flag_tile.platform_id)
        if platform then
          platform.res = filter
        end
      end
    end
  end
end

local on_mined_entity = function(event)
  check_tables()
  local entity = event.entity
  
  if entity and entity.name == "land-robot" then
    Robot.robots[entity.unit_number] = nil
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
    export_data()
  end
end)
