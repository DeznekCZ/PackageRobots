
require("control.queue")
require("control.pathfinder")

Robot = {
  robots = {},
  
  -- Robots which are registering
  register          = Queue.new(),
  -- Robots path calculation requests for run to rest point of pickup
  c_pickup_rest_run = Queue.new(),
  -- Robots path calculation requests for run to pickup
  c_pickup_run      = Queue.new(),
  -- Robots path calculation requests for run to rest point
  c_rest_run        = Queue.new(),
  -- Robots path calculation requests for run to drop point
  c_drop_run        = Queue.new(),

  run_wait     = Queue.new(), -- Robots running to Rest_Tile_X with waiting for free pickup
  iddle_wait   = Queue.new(), -- Robots waiting in Rest_Tile_X for free pickup
  run_pickup   = Queue.new(), -- Robots running to Pickup_Tile_X
  run_drop     = Queue.new(), -- Robots running to Drop_Tile_X
  
  fill         = Queue.new(), -- Robots waiting in Pickup_Tile_X for fill
  unload       = Queue.new(), -- Robots waiting in Drop_Tile_X for fill
  
  iddle        = Queue.new(), -- Robots waiting in Rest_Tile_X for free drop
  run_iddle    = Queue.new(), -- Robots running to Rest_Tile_X with waiting for free drop
  
  no_path     = Queue.new(), -- Robots with no path
  
  get = function(robot_id)
    return Robot.robots[robot_id]
  end,
  
  message = {
    tick = 0,
    no_path = function(robot, ticked) 
      if not ticked then return end
      robot.entity.surface.create_entity{
        name = "flying-text", 
        position = robot.entity.position, 
        text = {"land_logistic.state-no-path"},
        color = { r=1, g=0, b=0 }
      }
    end,
    
    iddle = function(robot)
      robot.entity.surface.create_entity{
        name = "flying-text", 
        position = robot.entity.position, 
        text = {"land_logistic.state-iddle"}
      }
    end,
    
    run_pickup = function(robot, resource) 
      robot.entity.surface.create_entity{
        name = "flying-text", 
        position = robot.entity.position, 
        text = { "land_logistic.state-resource", game.item_prototypes[resource].localised_name }
      }
    end,
    
    run_pickup_rest = function(robot, resource) 
      robot.entity.surface.create_entity{
        name = "flying-text", 
        position = robot.entity.position, 
        text = { "land_logistic.state-prepare-resource", game.item_prototypes[resource].localised_name }
      }
    end,
    
    calculating = function(robot) 
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
  and Robot.robots[tile_x.served] then
    return Robot.robots[tile_x.served]
  else
    return nil
  end
end

function Robot.free_resting(robot)
  local data = PATH_FINDER:data()
  for _,resting in pairs(data.resting) do
  	if not Robot.is_served(resting) then
  	  return resting
  	end
  end
  return nil
end

function Robot.free_pickup(pickup_p)
  local next_point
  for pickup_id, pickup_pos in pairs(pickup_p.tiles) do
    --log_actions("platform position type="..pickup_pos.dir)
    if pickup_pos.dir == "path-p" then
      --log_actions("tested pickup="..serpent.block(pickup_pos))
      next_point = PATH_FINDER:TILE_P(pickup_pos)
      if next_point and not Robot.is_served(next_point) then
        break
      else
        next_point = nil
      end
    end
  end
  return next_point
end

function Robot.search_job(robot) 
  -- SEARCHING FOR DROP
  --log_actions("searching of drop")
  for _,drop in pairs(global.land_logistic.drops) do
    if not Robot.is_served(drop) then goto next_drop end
    local drop_p = PATH_FINDER:PLATFORM(drop.platform_id)
    if (not drop_p) and (not drop_p.res) then goto next_drop end
    -- SEARCHING FOR PICKUP
    --log_actions("searching of pickup for platform="..drop_p.id)
    local next_point
    
    for _,pickup_p in pairs(global.land_logistic.platforms) do
      --log_actions("searching testing platform="..pickup_p.id)
      if drop_p.res == pickup_p.res then
        --log_actions("same resource="..drop_p.res)
        next_point = Robot.free_pickup(pickup_p)
        
        if not next_point then
          local get_rest = function(rest_id)
            local rest_point = global.land_logistic.resting[rest_id]
            if rest_point 
            and not Robot.is_served(rest_point) then
              local DP_sr = PATH_FINDER:register(robot.entity.surface, next_point, drop)
              if DP_sr.path then
                return rest_point
              end
            end
          end
          next_point = pickup_p.resting:for_each(get_rest)
        end
        
        if next_point then
          Robot.message.calculating(robot)
      
          robot.next_destination = position(next_point)
          robot.pickup_platform  = pickup_p
          robot.drop_platform    = drop_p
          robot.drop             = drop
          robot.drop.served      = robot.id
      
          if next_point.dir == "path-r" then
      	    Robot.c_pickup_rest_run:push(robot.id)
          elseif next_point.dir == "path-d" then
            Robot.c_drop_run:push(robot.id)
          else
            Robot.c_pickup_run:push(robot.id)
          end
          return true
        end
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
    tile = PATH_FINDER:TILE(math.floor(entity.position.x), math.floor(entity.position.y)),
    x = entity.position.x,
    y = entity.position.y
  }
  Robot.robots[robot.id] = robot
  if robot.tile then robot.tile.served = robot.id end
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
  local robot_tile = PATH_FINDER:TILE(math.floor(robot.x), math.floor(robot.y))
  local destination = robot.destination
  
  if not robot_tile then
  	Robot.message.no_path(robot, Robot.message.tick == 0)
  	return false
  end
  
  if destination then
  	return robot_tile.id == destination.id
  else
  	return false
  end
end

function Robot.unloaded(robot)
  return true -- TODO
end

function Robot.filled(robot)
  return true -- TODO
end

function Robot.check_path(CalcQueue, ResultQueue, ResultMessage)
  local tmp_q = Queue.new()
  while not CalcQueue:is_empty() do
    local robot = Robot.get(CalcQueue:pop())
    local tries = 1
    if robot.tile.platform and robot.next_destination.platform then
      tries = nil
    end
    game.print{"", "hleda cestu"}
    local search_result = 
        PATH_FINDER:register(robot.entity.surface, robot.tile, robot.next_destination, tries)
    if search_result.invalid and search_result.tries then
      Robot.message.no_path(robot, Robot.message.tick == 0)
      Robot.no_path:push(robot.id)
    elseif search_result.path then
      robot.destination = robot.next_destination
      robot.path = search_result.path
      ResultMessage(robot, robot.drop_platform.res)
      ResultQueue:push(robot.id)
    else
      tmp_q:push(robot.id)
    end
  end
  if not tmp_q:is_empty() then
    local push = function(entry)
      CalcQueue:push(entry)
    end
    tmp_q:for_each(push)
  end
end

function Robot.tick(tick)
  Robot.message.tick = tick % 40
  
  Robot.check_path(Robot.c_drop_run,        Robot.run_drop,   Robot.message.run_pickup_rest)
  Robot.check_path(Robot.c_pickup_rest_run, Robot.run_wait,   Robot.message.run_pickup_rest)
  Robot.check_path(Robot.c_pickup_run,      Robot.run_pickup, Robot.message.run_pickup)
  Robot.check_path(Robot.c_rest_run,        Robot.iddle_wait, Robot.message.iddle)
  
  while not Robot.register:is_empty() do
    local robot = Robot.get(Robot.register:pop())
    if robot and robot.tile then
      robot.tile.served = robot.id
      if robot.tile.dir == "path-r" then
      	Robot.message.iddle(robot)
        Robot.iddle:push(robot.id)
      else
      	robot.next_destination = Robot.free_resting(robot)
      	if robot.next_destination then
          Robot.message.calculating(robot)
	      Robot.c_rest_run:push(robot.id)
	    else
	      Robot.message.no_path(robot, true)
          Robot.no_path:push(robot.id)
	    end
      end
    elseif robot then
      Robot.message.no_path(robot, true)
      Robot.no_path:push(robot.id)
    end
  end
  
  -- @type Queue
  local tmp_q
  local push
  
  -- CHECK RUNNING
  tmp_q = Queue.new()
  while not Robot.run_iddle:is_empty() do
    local robot = Robot.get(Robot.run_iddle:pop())
    if robot and Robot.move(robot) then
      Robot.iddle:push(robot.id)
    elseif robot then
      tmp_q:push(robot.id)
    end
  end
  if not tmp_q:is_empty() then
  push = function(entry)
  	Robot.run_iddle:push(entry)
  end 
  tmp_q:for_each(push) end
  
  tmp_q = Queue.new()
  while not Robot.run_drop:is_empty() do
    local robot = Robot.get(Robot.run_drop:pop())
    if robot and Robot.move(robot) then
      Robot.unload:push(robot.id)
    elseif robot then
      tmp_q:push(robot.id)
    end
  end
  if not tmp_q:is_empty() then
  push = function(entry)
  	Robot.run_drop:push(entry)
  end 
  tmp_q:for_each(push) end
  
  tmp_q = Queue.new()
  while not Robot.run_pickup:is_empty() do
    local robot = Robot.get(Robot.run_pickup:pop())
    if robot and Robot.move(robot) then
      Robot.fill:push(robot.id)
    elseif robot then
      tmp_q:push(robot.id)
    end
  end
  if not tmp_q:is_empty() then
  push = function(entry)
  	Robot.run_pickup:push(entry)
  end 
  tmp_q:for_each(push) end
  
  tmp_q = Queue.new()
  while not Robot.fill:is_empty() do
    local robot = Robot.get(Robot.fill:pop())
    if robot and Robot.filled(robot) then
      robot.next_destination = robot.drop
      Robot.c_drop_run:push(robot.id)
    elseif robot then
      tmp_q:push(robot.id)
    end
  end
  if not tmp_q:is_empty() then
  push = function(entry)
  	Robot.fill:push(entry)
  end 
  tmp_q:for_each(push) end
  
  tmp_q = Queue.new()
  while not Robot.unload:is_empty() do
    local robot = Robot.get(Robot.unload:pop())
    if robot and Robot.unloaded(robot) then
      Robot.c_rest_run:push(robot.id)
    elseif robot then
      tmp_q:push(robot.id)
    end
  end
  if not tmp_q:is_empty() then
  push = function(entry)
  	Robot.unload:push(entry)
  end 
  tmp_q:for_each(push) end
  
  tmp_q = Queue.new()
  while not Robot.no_path:is_empty() do
    local robot = Robot.get(Robot.no_path:pop())
    if robot then
      local tile = PATH_FINDER:TILE_P(robot)
      if not tile or robot.entity.get_driver() then 
      	Robot.message.no_path(robot, Robot.message.tick == 0)
  	    tmp_q:push(robot.id)
      elseif tile and not robot.entity.get_driver() then
      	if not Robot.search_job(robot) then
      	  Robot.message.no_path(robot, Robot.message.tick == 0)
	      tmp_q:push(robot.id)
	    end
      end
    end
  end
  if not tmp_q:is_empty() then
  push = function(entry)
  	Robot.no_path:push(entry)
  end 
  tmp_q:for_each(push) end
  -- END OF ALL RUNNNING ROBOTS
  
  if (tick % 60) == 0 then
 -- IF EXISTS IN RESTING SLOTS WAITING ROBOTS
    tmp_q = Queue.new()
    while not Robot.iddle_wait:is_empty() do
      local robot = Robot.get(Robot.iddle_wait:pop())
      if robot then
        local free_pickup = Robot.free_pickup(robot.pickup_platform)
        if free_pickup then
          Robot.message.calculating(robot)
      
          robot.next_destination = free_pickup
          free_pickup.served     = robot.id
          
          Robot.c_pickup_rest_iddle:push(robot.id)
          dispach = true
        else
          tmp_q:push(robot.id)
        end
      end
    end
    if not tmp_q:is_empty() then
    push = function(entry)
        Robot.iddle_wait:push(entry)
    end 
    tmp_q:for_each(push) end
    
 -- IF EXISTS IN RESTING SLOTS WAITING ROBOTS
    tmp_q = Queue.new()
    while not Robot.run_wait:is_empty() do
      local robot = Robot.get(Robot.run_wait:pop())
      if robot then
        local free_pickup = Robot.free_pickup(robot.pickup_platform)
        if free_pickup then
          Robot.message.calculating(robot)
      
          robot.next_destination = free_pickup
          free_pickup.served     = robot.id
          
          Robot.c_pickup_rest_run:push(robot.id)
        else
          tmp_q:push(robot.id)
        end
      end
    end
    if not tmp_q:is_empty() then
    push = function(entry)
      Robot.run_wait:push(entry)
    end 
    tmp_q:for_each(push) end
    
 -- IF EXISTS IN RESTING SLOTS WAITING ROBOTS
    tmp_q = Queue.new()
    while not Robot.iddle:is_empty() do
      local robot = Robot.get(Robot.iddle:pop())
      if robot and not Robot.search_job(robot) then
        tmp_q:push(robot.id)
      end
    end
    if not tmp_q:is_empty() then
    push = function(entry)
      Robot.iddle:push(entry)
    end 
    tmp_q:for_each(push) end
    
 -- IF EXISTS IN RESTING SLOTS WAITING ROBOTS
    tmp_q = Queue.new()
    while not Robot.run_iddle:is_empty() do
      local robot = Robot.get(Robot.run_iddle:pop())
      if robot and not Robot.search_job(robot) then
        tmp_q:push(robot.id)
      end
    end
    if not tmp_q:is_empty() then
    push = function(entry)
      Robot.run_iddle:push(entry)
    end 
    tmp_q:for_each(push) end
  end
end