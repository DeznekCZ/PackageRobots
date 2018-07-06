data:extend(
{
  {
    type = "item",
    name = "void-material",
    icon = "__base__/graphics/icons/wall-remnants.png",
    enabled = true,
    icon_size = 32,
    flags = {"goes-to-main-inventory"},
    subgroup = "logistic-network",
    order = "a[robot]-a[logistic-robot]",
    stack_size = 1000
  },
  {
    type = "item",
    name = "assembling-machine-4",
    icon = "__base__/graphics/icons/assembling-machine-1.png",
    enabled = true,
    icon_size = 32,
    flags = {"goes-to-main-inventory"},
    subgroup = "logistic-network",
    order = "a[robot]-a[logistic-robot]",
    stack_size = 20,
    place_result = "assembling-machine-4"
  },
  {
    type = "recipe",
    name = "void-material",
    enabled = true,
    energy_required = 0.01,
    ingredients =
    {
      {"raw-wood", 1}
    },
    result = "void-material",
    result_count = 1000
  },
  {
    type = "recipe",
    name = "empty-barrel-void",
    enabled = true,
    energy_required = 0.01,
    ingredients =
    {
      {"empty-barrel", 1}
    },
    result = "void-material",
    result_count = 1
  },
  {
    type = "recipe",
    name = "steel-plate-void",
    enabled = true,
    energy_required = 0.01,
    ingredients =
    {
      {"void-material", 1}
    },
    result = "steel-plate",
    result_count = 1
  },
  {
    type = "recipe",
    name = "iron-plate-void",
    enabled = true,
    energy_required = 0.01,
    ingredients =
    {
      {"void-material", 1}
    },
    result = "iron-plate",
    result_count = 1
  },
  {
    type = "recipe",
    name = "advanced-circuit-void",
    enabled = true,
    energy_required = 0.01,
    ingredients =
    {
      {"void-material", 1}
    },
    result = "advanced-circuit",
    result_count = 1
  },
  {
    type = "recipe",
    name = "engine-unit-void",
    enabled = true,
    energy_required = 0.01,
    ingredients =
    {
      {"void-material", 1}
    },
    result = "engine-unit",
    result_count = 1
  },
  {
    type = "recipe",
    name = "copper-cable-void",
    enabled = true,
    energy_required = 0.01,
    ingredients =
    {
      {"void-material", 1}
    },
    result = "copper-cable"
  },
  {
    type = "recipe",
    name = "copper-plate-void",
    enabled = true,
    energy_required = 0.01,
    ingredients =
    {
      {"void-material", 1}
    },
    result = "copper-plate"
  },
  {
    type = "recipe",
    name = "concrete-void",
    enabled = true,
    energy_required = 0.01,
    ingredients =
    {
      {"void-material", 1}
    },
    result = "concrete"
  },
  {
    type = "recipe",
    name = "stone-brick-void",
    enabled = true,
    energy_required = 0.01,
    ingredients =
    {
      {"void-material", 1}
    },
    result = "stone-brick"
  },
  {
    type = "recipe",
    name = "electronic-circuit-void",
    enabled = true,
    energy_required = 0.01,
    ingredients =
    {
      {"void-material", 1}
    },
    result = "electronic-circuit"
  },
  {
    type = "recipe",
    name = "water-barel-void",
    enabled = true,
    energy_required = 0.01,
    ingredients =
    {
      {"void-material", 1}
    },
    result = "water-barrel"
  },
  {
    type = "recipe",
    name = "solid-fuel-void",
    enabled = true,
    energy_required = 0.01,
    ingredients =
    {
      {"void-material", 1}
    },
    result = "solid-fuel"
  },
  {
    type = "recipe",
    name = "solid-fuel-void",
    enabled = true,
    energy_required = 0.01,
    ingredients =
    {
      {"void-material", 1}
    },
    result = "solid-fuel"
  },
  {
    type = "recipe",
    name = "assembling-machine-4-void",
    enabled = true,
    energy_required = 0.01,
    ingredients =
    {
      {"void-material", 1}
    },
    result = "assembling-machine-4"
  }--[[,
  {
    type = "item",
    name = "concrete-path",
    icon = "__PackageRobots__/graphics/icons/concrete-path.png",
    icon_size = 32,
    flags = {"goes-to-quickbar"},
    subgroup = "logistic-network",
    order = "p[concrete]-a[plain]",
    stack_size = 100,
    place_as_tile =
    {
      result = "concrete-path-a",
      condition_size = 1,
      condition = { "water-tile" }
    }
  },
  concrete_path("PackageRobots", "a", "n", "",  {r=0, g=0.5, b=0.8}, {"ground-tile", "layer-14", "item-layer", "object-layer"}),
  concrete_path("PackageRobots", "w", "a", "",  {r=0, g=0.5, b=0.8}, {"ground-tile", "layer-14", "item-layer", "object-layer"})
--[[]]})

data.raw["recipe"]["hazard-concrete"].enabled = true
data.raw["recipe"]["fast-inserter"].enabled = true
data.raw["recipe"]["filter-inserter"].enabled = true
data.raw["recipe"]["stack-inserter"].enabled = true
data.raw["recipe"]["stack-filter-inserter"].enabled = true
data.raw["recipe"]["steel-chest"].enabled = true
data.raw["recipe"]["empty-water-barrel"].enabled = true
data.raw["recipe"]["fill-water-barrel"].enabled = true

data.raw["assembling-machine"]["assembling-machine-4"] = util.table.deepcopy(data.raw["assembling-machine"]["assembling-machine-1"])
data.raw["assembling-machine"]["assembling-machine-4"].name = "assembling-machine-4"
data.raw["assembling-machine"]["assembling-machine-4"].crafting_categories = {"crafting", "advanced-crafting", "crafting-with-fluid"}
data.raw["assembling-machine"]["assembling-machine-4"].crafting_speed = 5
data.raw["assembling-machine"]["assembling-machine-4"].energy_source =
    {
      type = "burner",
      fuel_category = "chemical",
      effectivity = 1,
      emissions = 0.02,
      fuel_inventory_size = 1,
      smoke =
      {
        {
          name = "smoke",
          frequency = 10,
          position = {0.7, -1.2},
          starting_vertical_speed = 0.08,
          starting_frame_deviation = 60
        }
      }
    }
data.raw["assembling-machine"]["assembling-machine-4"].fluid_boxes =
    {
      {
        production_type = "input",
        pipe_picture = assembler2pipepictures(),
        pipe_covers = pipecoverspictures(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {0, -2} }},
        secondary_draw_orders = { north = -1 }
      },
      {
        production_type = "output",
        pipe_picture = assembler2pipepictures(),
        pipe_covers = pipecoverspictures(),
        base_area = 10,
        base_level = 1,
        pipe_connections = {{ type="output", position = {0, 2} }},
        secondary_draw_orders = { north = -1 }
      },
      off_when_no_fluid_recipe = true
    }
data.raw["assembling-machine"]["assembling-machine-4"].minable = {hardness = 0.2, mining_time = 0.5, result = "assembling-machine-4"}
