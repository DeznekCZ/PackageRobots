function water_transition_template(to_tiles, normal_res_transition, high_res_transition, options)
  local function make_transition_variation(src_x, src_y, cnt_, line_len_, is_tall)
    return
    {
      picture = normal_res_transition,
      count = cnt_,
      line_length = line_len_,
      x = src_x,
      y = src_y,
      tall = is_tall,
      hr_version=
      {
        picture = high_res_transition,
        count = cnt_,
        line_length = line_len_,
        x = 2 * src_x,
        y = 2 * (src_y or 0),
        tall = is_tall,
        scale = 0.5,
      }
    }
  end

  local t = options.base or {}
  t.to_tiles = to_tiles
  local default_count = options.count or 16
  for k,y in pairs({inner_corner = 0, outer_corner = 288, side = 576, u_transition = 864, o_transition = 1152}) do
    local count = options[k .. "_count"] or default_count
    if count > 0 and type(y) == "number" then
      local line_length = options[k .. "_line_length"] or count
      local is_tall = true
      if (options[k .. "_tall"] == false) then
        is_tall = false
      end
      t[k] = make_transition_variation(0, y, count, line_length, is_tall)
      t[k .. "_background"] = make_transition_variation(544, y, count, line_length, is_tall)
      t[k .. "_mask"] = make_transition_variation(1088, y, count, line_length)
    end
  end

  return t
end

local concrete_transitions =
{
  water_transition_template
  (
      water_tile_type_names,
      "__base__/graphics/terrain/water-transitions/concrete.png",
      "__base__/graphics/terrain/water-transitions/hr-concrete.png",
      {
        o_transition_tall = false,
        u_transition_count = 4,
        o_transition_count = 4,
        side_count = 8,
        outer_corner_count = 8,
        inner_corner_count = 8,
        --base = { layer = 40 }
      }
  ),
}

local concrete_transitions_between_transitions =
{
  water_transition_template
  (
      water_tile_type_names,
      "__base__/graphics/terrain/water-transitions/concrete-transitions.png",
      "__base__/graphics/terrain/water-transitions/hr-concrete-transitions.png",
      {
        inner_corner_tall = true,
        inner_corner_count = 3,
        outer_corner_count = 3,
        side_count = 3,
        u_transition_count = 1,
        o_transition_count = 0,
      }
  ),
}

-- UPDATE WHEN IS NEW VERSION 

local function path(type, direction, next_direction)
  local rtype = ""
  
  if type ~= "" then
    rtype = type .. "-"
  end

  return {
    type = "tile",
    name = rtype .. "concrete-path-" .. direction,
    needs_correction = false,
    next_direction = rtype .. "concrete-path-" .. next_direction,
    minable = {hardness = 0.2, mining_time = 0.5, result = rtype .. "concrete-path"},
    mined_sound = { filename = "__base__/sound/deconstruct-bricks.ogg" },
    collision_mask = {"ground-tile"},
    walking_speed_modifier = 1.4,
    layer = 61,
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
      inner_corner =
      {
        picture = "__base__/graphics/terrain/concrete/concrete-inner-corner.png",
        count = 16,
        hr_version = {
          picture = "__base__/graphics/terrain/concrete/hr-concrete-inner-corner.png",
          count = 16,
          scale = 0.5
        },
      },
      inner_corner_mask =
      {
        picture = "__base__/graphics/terrain/concrete/concrete-inner-corner-mask.png",
        count = 16,
        hr_version = {
          picture = "__base__/graphics/terrain/concrete/hr-concrete-inner-corner-mask.png",
          count = 16,
          scale = 0.5
        },
      },

      outer_corner =
      {
        picture = "__base__/graphics/terrain/concrete/concrete-outer-corner.png",
        count = 8,
        hr_version = {
          picture = "__base__/graphics/terrain/concrete/hr-concrete-outer-corner.png",
          count = 8,
          scale = 0.5
        },
      },
      outer_corner_mask =
      {
        picture = "__base__/graphics/terrain/concrete/concrete-outer-corner-mask.png",
        count = 8,
        hr_version = {
          picture = "__base__/graphics/terrain/concrete/hr-concrete-outer-corner-mask.png",
          count = 8,
          scale = 0.5
        },
      },

      side =
      {
        picture = "__base__/graphics/terrain/concrete/concrete-side.png",
        count = 16,
        hr_version = {
          picture = "__base__/graphics/terrain/concrete/hr-concrete-side.png",
          count = 16,
          scale = 0.5
        },
      },
      side_mask =
      {
        picture = "__base__/graphics/terrain/concrete/concrete-side-mask.png",
        count = 16,
        hr_version = {
          picture = "__base__/graphics/terrain/concrete/hr-concrete-side-mask.png",
          count = 16,
          scale = 0.5
        },
      },

      u_transition =
      {
        picture = "__base__/graphics/terrain/concrete/concrete-u.png",
        count = 8,
        hr_version = {
          picture = "__base__/graphics/terrain/concrete/hr-concrete-u.png",
          count = 8,
          scale = 0.5
        },
      },
      u_transition_mask =
      {
        picture = "__base__/graphics/terrain/concrete/concrete-u-mask.png",
        count = 8,
        hr_version = {
          picture = "__base__/graphics/terrain/concrete/hr-concrete-u-mask.png",
          count = 8,
          scale = 0.5
        },
      },

      o_transition =
      {
        picture = "__base__/graphics/terrain/concrete/concrete-o.png",
        count = 4,
        hr_version = {
          picture = "__base__/graphics/terrain/concrete/hr-concrete-o.png",
          count = 4,
          scale = 0.5
        },
      },
      o_transition_mask =
      {
        picture = "__base__/graphics/terrain/concrete/concrete-o-mask.png",
        count = 4,
        hr_version = {
          picture = "__base__/graphics/terrain/concrete/hr-concrete-o-mask.png",
          count = 4,
          scale = 0.5
        },
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

    transitions = concrete_transitions,
    transitions_between_transitions = concrete_transitions_between_transitions,

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
    map_color={r=100, g=100, b=100},
    ageing=0,
    vehicle_friction_modifier = concrete_vehicle_speed_modifier
  }
end

data:extend(
{
  path("PackageRobots", "", "n", "e"),
  path("PackageRobots", "", "e", "s"),
  path("PackageRobots", "", "s", "w"),
  path("PackageRobots", "", "w", "n")
})
