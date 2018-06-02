
local init = function()
  if not global.land_logistic then global.land_logistic = {} end
  
  local ll = global.land_logistic
  if not ll.drops        then ll.drops        = {} end -- unload positions
  if not ll.pickups      then ll.pickups      = {} end -- load positions
  if not ll.junctions    then ll.junctions    = {} end -- all junction tiles
  if not ll.tiles        then ll.tiles        = {} end -- all direction tiles
  if not ll.robots       then ll.robots       = {} end -- list of robots
  if not ll.paths        then ll.paths        = {} end -- pre-calculated paths
  
  
end

local get_net = function(robot)
  if robot.entity.valid then
    local entity = robot.entity
    local tile = entity.surface.get_tile(entity.position.x, entity.position.y)
    if string.find(tile.name, "concrete-path-") then
      
    end
  end
  return -1
end

local search_job = function(robot, no_requests) 
  -- SEARCHING FOR DROP
  local found_drop = false
  for _,drop in pairs(global.land_logistic.drops) do
    if drop.net == robot.net then
      -- SEARCHING FOR PICKUP
      local found_pickup = false
      for _,pickup in pairs(global.land_logistic.pickups) do
        if pickup.net == robot.net and drop.res = pickup.res then
          robot.path = get_path(pickup, drop)
          robot.state = 1 --[[RUN_FICKUP]]
          drop.served = robot.id
          return
        end
      end
    end
  end
  no_requests[robot.net] = true
end

local on_tick = function(event)
--  game.print(global.land_logistic.robots.count or 0)
  
  local no_requests = {}
  for _, robot in pairs(global.land_logistic.robots) do
    if robot.net ~= -1 then
      if robot.state == 0 --[[IDDLE]] and not no_requests[robot.net] then
        search_job(robot, no_requests)
      end
    else
      if robot.entity.valid then
        robot.net = get_net(robot.entity.position)
      end
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
      net = get_net(entity.position)
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