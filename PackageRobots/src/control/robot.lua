
require("control.queue")

Robot = {
  robots = {}
  
  register    = Queue.new(), -- Robots which are registering

  run_wait    = Queue.new(), -- Robots running to Rest_Tile_X with waiting for free pickup
  iddle_wait  = Queue.new(), -- Robots waiting in Rest_Tile_X for free pickup
  run_pickup  = Queue.new(), -- Robots running to Pickup_Tile_X
  run_drop    = Queue.new(), -- Robots running to Drop_Tile_X
  
  iddle       = Queue.new(), -- Robots waiting in Rest_Tile_X for free drop
  run_iddle   = Queue.new(), -- Robots running to Rest_Tile_X with waiting for free drop
  
  no_path     = Queue.new(), -- Robots with no path
  
  get = function(robot_id)
    return robots[robot_id]
  end,
  
  message = {
    tick = 0,
    no_path = function(robot, ticked) 
      if ticked and tick ~= 0 then return end
      robot.entity.surface.create_entity{
        name = "flying-text", 
        position = robot.entity.position, 
        text = {"land_logistic.state-no-path"},
        color = { r=1, g=0, b=0 }
      }
    end,
    
    iddle = function(robot) 
      if tick ~= 0 then return end
      robot.entity.surface.create_entity{
        name = "flying-text", 
        position = robot.entity.position, 
        text = {"land_logistic.state-iddle"}
      }
    end,
    
    run_pickup = function(robot, resource) 
      if ticked and tick ~= 0 then return end
      robot.entity.surface.create_entity{
        name = "flying-text", 
        position = robot.entity.position, 
        text = { "land_logistic.state-resource", game.item_prototypes[resource].localised_name }
      }
    end,
    
    calculating = function(robot, resource) 
      if ticked and tick ~= 0 then return end
      robot.entity.surface.create_entity{
        name = "flying-text", 
        position = robot.entity.position, 
        text = { "land_logistic.state-calculating" }
      }
    end,
  }
}

function Robot.is_served(tile_x)
  if tile_x 
  and tile_x.served 
  and Robot.robots[tile_x.served]
  and Robot.robots[tile_x.served].id == tile_x.served then
    return Robot.robots[tile_x.served]
  else
    return nil
  end
end

function Robot.free_pickup(drop, pickup_p)
  local next_point
  for pickup_id, pickup_pos in pairs(pickup_p.tiles) do
    --log_actions("platform position type="..pickup_pos.dir)
    if pickup_pos.dir == "path-p" then
      --log_actions("tested pickup="..serpent.block(pickup_pos))
      next_point = get_tile_round(pickup_pos.x, pickup_pos.y)
      if next_point and not Robot.is_served(next_point) then
        local DP_sr = global.land_logistic.PATH_FINDER:register(robot.entity.surface, next_point, drop)
        if DP_sr.path then
          break
        end
      end
    end
  end
  return next_point
end

function Robot.search_job(robot, queue) 
  -- SEARCHING FOR DROP
  --log_actions("searching of drop")
  for _,drop in pairs(global.land_logistic.drops) do
    if not Robot.is_served(drop) then goto next_drop end
    local drop_p = get_platform_by_id(drop.platform_id)
    if (not drop_p) and (not drop_p.res) then goto next_drop end
    -- SEARCHING FOR PICKUP
    --log_actions("searching of pickup for platform="..drop_p.id)
    local next_point
    
    for _,pickup_p in pairs(global.land_logistic.platforms) do
      --log_actions("searching testing platform="..pickup_p.id)
      if drop_p.res == pickup_p.res then
        --log_actions("same resource="..drop_p.res)
        next_point = Robot.free_pickup(drop, pickup_p)
        
        if next_point then
          goto point_found
        end
         
        next_point = pickup_p.resting:for_each(function(rest_id)
          local rest_point = global.land_logistic.resting[rest_if]
          if rest_point 
          and not Robot.get(rest_point.served) then
            local DP_sr = global.land_logistic.PATH_FINDER:register(robot.entity.surface, next_point, drop)
              if DP_sr.path then
                return rest_point
              end
            end
          end
        end)
        
        if next_point then
          goto point_found
        end
      end
    
      goto next_drop
      ::point_found::
      
      Robot.message.calculating(robot)
      
      robot.next_destination = position(next_point)
      robot.pickup_platform  = pickup_p
      robot.drop_platform    = drop_p
      robot.drop             = drop
      robot.drop.served      = robot.id
      robot.last_queue       = queue
      
      Robot.calculation.push(robot.id)
      return true
      end
    end
    ::next_drop::
  end
  return false
end

function Robot.create(entity)
  local robot = {
    id = entity.unit_number,
    entity = entity,
    tile = global.land_logistic.PATH_FINDER:TILE(entity.position.x, entity.position.y)
  }
  Robot.robots[robot.id] = robot
  Robot.register:push(robot.id)
  return robot
end

--[[
  Robot_E = {
    id = entity.unit_umber,
    entity,
    tile, -- last visited point
  }
]]
function Robot.move(robot)
  
end

function Robot.tick(tick, surface)
  Robot.message.tick = tick % 60
  Robot.surface = surface
  
  while not Robot.calculation:is_empty() do
    local robot = Robot.get(Robot.calculation:pop())
    local search_result = 
        global.land_logistic.PATH_FINDER:register(robot.entity.surface, robot.tile, robot.next_destination, 1)
    if search_result.invalid and search_result.tries then
      robot.last_queue:push(robot.id)
      robot.drop.served = nil
    elseif search_result.path then
      robot.destination = robot.next_destination
      robot.path = search_result.path
      Robot.message.run_pickup(robot, robot.drop_platform.res)
      if robot.tile.dir == "path-r" then
        Robot.run_wait:push(robot.id)
      else
        robot.last_queue:push(robot.id)
      end
    end
  end
  
  while not Robot.register:is_empty() do
    local robot = Robot.get(Robot.register:pop())
    if robot.tile then
      robot.tile.served = robot.id
      Robot.message.iddle(robot)
      if robot.tile.dir == "path-r" then
        Robot.iddle:push(robot.id)
      else
        Robot.run_iddle:push(robot.id)
      end
    else
      Robot.message.no_path(robot)
      Robot.no_path:push(robot.id)
    end
  end
  
  while not Robot.run_iddle:is_empty() do
    local robot = Robot.get(Robot.run_iddle:pop())
    if robot and Robot.move(robot) then
      Robot.iddle:push(robot.id)
    else
      Robot.run_iddle:push(robot.id)
    end
  end
  
  while not Robot.run_pickup:is_empty() do
    local robot = Robot.get(Robot.run_iddle:pop())
    if robot and Robot.move(robot) then
      Robot.run_drop:push(robot.id)
    else
      Robot.run_pickup:push(robot.id)
    end
  end
  
  if (event.tick % 30) == 0 then
 -- IF EXISTS IN RESTING SLOTS WAITING ROBOTS
    if not Robot.iddle_wait:is_empty() then
      local robot = Robot.get(Robot.run_iddle:pop())
      if robot then
        free_pickup = Robot.free_pickup(robot.drop, robot.pickup_platform)
        if free_pickup then
          Robot.message.calculating(robot)
      
          robot.next_destination = position(next_point)
          robot.last_queue       = Robot.iddle_wait
          free_pickup.served     = robot.id
          
          Robot.calculation.push(robot.id)
        end
      end
    end
    
 -- IF EXISTS IN RESTING SLOTS WAITING ROBOTS
    if not dispach and not Robot.run_wait:is_empty() then
      local robot = Robot.get(Robot.run_iddle:pop())
      if robot then
        free_pickup = Robot.free_pickup(robot.drop, robot.pickup_platform)
        if free_pickup then
          Robot.message.calculating(robot)
      
          robot.next_destination = position(next_point)
          robot.last_queue       = Robot.run_wait
          free_pickup.served     = robot.id
          
          Robot.calculation.push(robot.id)
        end
      end
    end
    
 -- IF EXISTS IN RESTING SLOTS WAITING ROBOTS
    if not dispach and not Robot.iddle:is_empty() then
      local robot = Robot.get(Robot.iddle:pop())
      if robot and not search_job(robot, Robot.iddle) then
        Robot.iddle:push(robot.id)
      end
    end
    
 -- IF EXISTS IN RESTING SLOTS WAITING ROBOTS
    if not dispach and not Robot.run_iddle:is_empty() then
      local robot = Robot.get(Robot.run_iddle:pop())
      if robot and not search_job(robot, Robot.run_iddle) then
        Robot.run_iddle:push(robot.id)
      end
    end
  end
end