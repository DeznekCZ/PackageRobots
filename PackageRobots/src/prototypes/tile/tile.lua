
local function path(mod, type, direction, next_direction, color)
  local rtype = ""
  
  if type ~= "" then
    rtype = type .. "-"
  end

  return {
    type = "tile",
    name = rtype .. "concrete-path-" .. direction,
    needs_correction = false,
    transition_merges_with_tile = "concrete",
    next_direction = rtype .. "concrete-path-" .. next_direction,
    minable = {hardness = 0.2, mining_time = 0.5, result = rtype .. "concrete-path"},
    mined_sound = { filename = "__base__/sound/deconstruct-bricks.ogg" },
    collision_mask = {"ground-tile"},
    walking_speed_modifier = 1.4,
    layer = 62,
    transition_overlay_layer_offset = 2, -- need to render border overlay on top of hazard-concrete
    decorative_removal_probability = 0.25,
    variants =
    {
      main =
      {
        {
          picture = "__base__/graphics/terrain/concrete/concrete-dummy.png",
          count = 1,
          size = 1
        },
        {
          picture = "__base__/graphics/terrain/concrete/concrete-dummy.png",
          count = 1,
          size = 2,
          probability = 0.39
        },
        {
          picture = "__base__/graphics/terrain/concrete/concrete-dummy.png",
          count = 1,
          size = 4,
          probability = 1
        },
      },
      inner_corner_mask =
      {
        picture = "__base__/graphics/terrain/concrete/hazard-concrete-inner-corner-mask.png",
        count = 1
      },
      outer_corner_mask =
      {
        picture = "__base__/graphics/terrain/concrete/hazard-concrete-outer-corner-mask.png",
        count = 1
      },

      side_mask =
      {
        picture = "__base__/graphics/terrain/concrete/hazard-concrete-side-mask.png",
        count = 1
      },

      u_transition_mask =
      {
        picture = "__base__/graphics/terrain/concrete/hazard-concrete-u-mask.png",
        count = 1
      },

      o_transition_mask =
      {
        picture = "__base__/graphics/terrain/concrete/hazard-concrete-o-mask.png",
        count = 1
      },


      material_background =
      {
        picture = "__" .. mod .. "__/graphics/terrain/concrete/" .. rtype .. "concrete-" .. direction .. ".png",
        count = 8,
        hr_version =
        {
          picture = "__" .. mod .. "__/graphics/terrain/concrete/hr-" .. rtype .. "concrete-" .. direction .. ".png",
          count = 8,
          scale = 0.5
        }
      }
    },

    walking_sound =
    {
      {
        filename = "__base__/sound/walking/concrete-01.ogg",
        volume = 1.0
      },
      {
        filename = "__base__/sound/walking/concrete-02.ogg",
        volume = 1.0
      },
      {
        filename = "__base__/sound/walking/concrete-03.ogg",
        volume = 1.0
      },
      {
        filename = "__base__/sound/walking/concrete-04.ogg",
        volume = 1.0
      }
    },
    map_color=color,
    ageing=0,
    vehicle_friction_modifier = concrete_vehicle_speed_modifier
  }
end

data:extend(
{
  path("PackageRobots", "", "n", "e", {r=0, g=0.6, b=0.9}),
  path("PackageRobots", "", "e", "s", {r=0, g=0.6, b=0.9}),
  path("PackageRobots", "", "s", "w", {r=0, g=0.6, b=0.9}),
  path("PackageRobots", "", "w", "n", {r=0, g=0.6, b=0.9}),
  path("PackageRobots", "", "j", "j", {r=0, g=0.5, b=0.9}),
  path("PackageRobots", "", "d", "p", {r=0, g=0.6, b=0.8}),
  path("PackageRobots", "", "p", "d", {r=0, g=0.6, b=0.8})
})
