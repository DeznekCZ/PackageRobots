--[[
  PackageRobots - control.lua
  
  Author: Zdenek Novotny (DeznekCZ)
]]
require("control.queue")
require("control.pathfinder")
require("control.robot")

local function reset_log() 
  game.write_file("land_logistic.log", "", false)
end

local function log_actions(text) 
  game.write_file("land_logistic.log", text .. "\n", true)
end

local function export_data() 
  game.write_file("land_logistic.lua", "global.land_logistic " .. serpent.block(global.land_logistic) .. "\n", false)
  game.write_file("land_logistic.lua", "PATH_FINDER " .. serpent.block(PATH_FINDER) .. "\n", true)
  game.write_file("land_logistic.lua", "Robot " .. serpent.block(Robot) .. "\n", true)
end

local init = function()
  if not global.land_logistic then global.land_logistic = {} end
  if not global.land_logistic.path_finder then
    PATH_FINDER = PathFinder.new()
  else
  	PATH_FINDER = PathFinder.restore(global.land_logistic)
  end
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
  
  if not ll.path_finder then
  	 ll.path_finder = PATH_FINDER
  end
  
  if ll.robots then
  	Robot.robots = ll.robots
  	Robot.init_queues(ll)
  else
  	ll.robots = Robot.robots
  	Robot.copy_queues(ll)
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

local function get_tile_round(x, y)
  local x_path = global.land_logistic.tiles[x]
  if x_path then 
    return x_path[y]
  else 
    return nil
  end
  --]]
end

local function calculate_rest_points(platform)
  local resting = Queue.new()
  global.land_logistic.rest_calc = Queue.restore(global.land_logistic.path_calc)
  local ref_point = position(global.land_logistic.drops[platform.id] or global.land_logistic.pickups[platform.id] or global.land_logistic.flags[platform.id])
  for rest_id, rest in pairs(global.land_logistic.resting) do
  	PATH_FINDER:register(game.surfaces[1], rest, ref_point, 1)
  	global.land_logistic.rest_calc:push({resting = position(rest), platform = ref_point})
  end
end

local function get_tile(fx, fy)
  local x = math.floor(fx)
  local y = math.floor(fy)
  return get_tile_round(x, y)
  --]]
end

local function init_tile(tile_x)
  local dir = tile_x.dir
  
  tile_x.platform = (tile_x.dir == "path-p")
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
  
  if tile_x.platform then
    global.land_logistic.platforms[id] = tile_x
    
    return true
  elseif tile_x.resting then    
    global.land_logistic.resting[id] = tile_x
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
  end
  --]]
end

local function check_filters()
  for flag_id, flag in pairs(global.land_logistic.filters) do 
    if flag and flag.valid then
      local tile_x = get_tile(flag.position.x, flag.position.y)
      local platform = global.land_logistic.platforms[tile_x.platform_id]
      platform.res = flag.get_filter(1)
    else
     global.land_logistic.filters[flag_id] = nil
    end
  end
  --]]
end

local on_tick = function(event)
  --[[ do nothing until will be fixed
  check_tables()
  check_filters()
  
  global.land_logistic.rest_calc = Queue.restore(global.land_logistic.path_calc)
  local tmp_q = Queue.new()
  while not global.land_logistic.rest_calc:is_empty() do
    local path = global.land_logistic.rest_calc:pop()
    if path then
  	  local result = PATH_FINDER:register(game.surfaces[1], path.resting, path.platform, 1)
  	  local platform_tile = PATH_FINDER:TILE_P(path.platform)
  	  local platform
  	  if platform_tile then platform = global.land_logistic.platforms[platform_tile.platform_id] end
  	  if result.path and platform then
  	    Queue.restore(platform.resting):push(Queue.restore(result.path):length())
  	  elseif result.invalid and not result.tries then
  	    tmp_q:push(path)
  	  end
  	end
  end
  if not tmp_q:is_empty() then
    local push = function(entry)
      Robot.run_wait:push(entry)
    end 
    tmp_q:for_each(push)
  end
  
  PATH_FINDER:tick()
  
  Robot.tick(event.tick)
  --]]
end

local on_built_tile = function(event)
  --[[
  check_tables()
  local surface
  if event.player_index then surface = game.players[event.player_index].surface end
  if event.robot then surface = event.robot.surface end
  
  local tiles = event.tiles
  for _,tile in pairs(tiles) do
    set_tile(tile.position.x, tile.position.y, surface.get_tile(tile.position.x, tile.position.y))
  end
  --]]
end

local function on_mined_tile(event)
  --[[
  check_tables()
  local tiles = event.tiles
  for _,tile in pairs(tiles) do
    set_tile(tile.position.x, tile.position.y, nil)
  end
  --]]
end

local on_built_entity = function(event)
  --[[
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
  --]]
end

local on_mined_entity = function(event)
  --[[
  check_tables()
  local entity = event.entity
  
  if entity and entity.name == "land-robot" then
    Robot.robots[entity.unit_number] = nil
  end
  --]]
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
