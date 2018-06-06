
function concrete_path(mod, direction, next_direction, pickup_direction, color, collision)
  local rpickup = ""
  
  if pickup_direction ~= "" then
    rpickup = "-" .. pickup_direction
  end

  return {
    type = "tile",
    name = "concrete-path-" .. direction,
    needs_correction = false,
    next_direction = "concrete-path-" .. next_direction,
    transition_merges_with_tile = "concrete",
    minable = {hardness = 0.2, mining_time = 0.5, result = "concrete-path" .. rpickup},
    mined_sound = { filename = "__base__/sound/deconstruct-bricks.ogg" },
    collision_mask = collision,
    walking_speed_modifier = 1.4,
    layer = 62,
    transition_overlay_layer_offset = 2, -- need to render border overlay on top of hazard-concrete
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
        picture = "__base__/graphics/terrain/concrete/concrete-dummy.png",
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
        picture = "__" .. mod .. "__/graphics/terrain/concrete/concrete-" .. direction .. ".png",
        count = 8,
        hr_version =
        {
          picture = "__" .. mod .. "__/graphics/terrain/concrete/hr-concrete-" .. direction .. ".png",
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
  concrete_path("PackageRobots", "n", "e", "",  {r=0, g=0.6, b=0.9}, {"ground-tile", "layer-14", "item-layer", "object-layer"}),
  concrete_path("PackageRobots", "e", "s", "",  {r=0, g=0.6, b=0.9}, {"ground-tile", "layer-14", "item-layer", "object-layer"}),
  concrete_path("PackageRobots", "s", "w", "",  {r=0, g=0.6, b=0.9}, {"ground-tile", "layer-14", "item-layer", "object-layer"}),
  concrete_path("PackageRobots", "w", "n", "",  {r=0, g=0.6, b=0.9}, {"ground-tile", "layer-14", "item-layer", "object-layer"}),
  concrete_path("PackageRobots", "j", "x", "i", {r=0, g=0.6, b=0.8}, {"ground-tile", "layer-14", "item-layer", "object-layer"}),
  concrete_path("PackageRobots", "x", "j", "i", {r=0, g=0.6, b=0.8}, {"ground-tile", "layer-14", "item-layer", "object-layer"}),
  concrete_path("PackageRobots", "d", "p", "c", {r=0, g=0.5, b=0.8}, {"ground-tile", "layer-14", "item-layer", "object-layer"}),
  concrete_path("PackageRobots", "p", "r", "c", {r=0, g=0.5, b=0.8}, {"ground-tile", "layer-14", "item-layer", "object-layer"}),
  concrete_path("PackageRobots", "r", "l", "c", {r=0, g=0.6, b=0.7}, {"ground-tile", "layer-14", "item-layer", "object-layer"}),
  concrete_path("PackageRobots", "l", "p", "c", {r=0, g=0.5, b=0.9}, {"item-layer", "object-layer"})
})
