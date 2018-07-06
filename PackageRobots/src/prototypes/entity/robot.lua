data:extend(
{
  {
    type = "car",
    name = "land-robot",
    icon = "__base__/graphics/icons/logistic-robot.png",
    icon_size = 32,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 1, result = "land-robot"},
    mined_sound = {filename = "__core__/sound/deconstruct-medium.ogg"},
    max_health = 50,
    corpse = "small-remnants",
    alert_icon_shift = util.by_pixel(0, -13),
    energy_per_hit_point = 1,
    crash_trigger = crash_trigger(),
    resistances =
    {
      {
        type = "fire",
        percent = 50
      },
      {
        type = "impact",
        percent = 30,
        decrease = 50
      }
    },
    collision_box = {{-0.5, -0.5}, {0.5, 0.5}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    effectivity = 0.5,
    braking_power = "200kW",

    burner =
    {
      fuel_category = "chemical",
      effectivity = 0.6,
      fuel_inventory_size = 1,
      smoke =
      {
        {
          name = "smoke",
          deviation = {0.1, 0.1},
          frequency = 9
        }
      }
    },
    consumption = "10kW",
    friction = 1e-3,
    light =
    {
      {
        type = "oriented",
        minimum_darkness = 0.3,
        picture =
        {
          filename = "__core__/graphics/light-cone.png",
          priority = "extra-high",
          flags = { "light" },
          scale = 2,
          width = 200,
          height = 200
        },
        shift = {0, -10},
        size = 2,
        intensity = 0.6,
        color = {r = 0.92, g = 0.77, b = 0.3}
      }
    },
    render_layer = "object",
    animation =
    {
      layers =
      {
        {
          filename = "__base__/graphics/entity/logistic-robot/logistic-robot.png",
          priority = "high",
          line_length = 16,
          width = 41,
          height = 42,
          frame_count = 1,
          shift = {0.015625, -0.09375},
          direction_count = 16,
          hr_version = {
            filename = "__base__/graphics/entity/logistic-robot/hr-logistic-robot.png",
            priority = "high",
            line_length = 16,
            width = 80,
            height = 84,
            frame_count = 1,
            shift = util.by_pixel(0, -3),
            direction_count = 16,
            scale = 0.5
          }
        }
      }
    },
    sound_no_fuel =
    {
      {
        filename = "__base__/sound/fight/car-no-fuel-1.ogg",
        volume = 0.2
      }
    },
    stop_trigger_speed = 0.2,
    stop_trigger =
    {
      {
        type = "play-sound",
        sound =
        {
          {
            filename = "__base__/sound/car-breaks.ogg",
            volume = 0.2
          }
        }
      }
    },
    sound_minimum_speed = 0.2;
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    working_sound =
    {
      sound =
      {
        filename = "__base__/sound/car-engine.ogg",
        volume = 0.2
      },
      activate_sound =
      {
        filename = "__base__/sound/car-engine-start.ogg",
        volume = 0.2
      },
      deactivate_sound =
      {
        filename = "__base__/sound/car-engine-stop.ogg",
        volume = 0.2
      },
      match_speed_to_activity = true,
    },
    open_sound = { filename = "__base__/sound/car-door-open.ogg", volume=0.7 },
    close_sound = { filename = "__base__/sound/car-door-close.ogg", volume = 0.7 },
    rotation_speed = 0.01,
    weight = 100,
    guns = { },
    inventory_size = 10,
    tank_driving = true
  }
})