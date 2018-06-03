data:extend(
{
  {
    type = "item",
    name = "void-material",
    icon = "__base__/graphics/icons/wall-remnants.png",
    icon_size = 32,
    flags = {"goes-to-main-inventory"},
    subgroup = "logistic-network",
    order = "a[robot]-a[logistic-robot]",
    stack_size = 1000
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
  }
})

data.raw["recipe"]["hazard-concrete"].enabled = true
data.raw["recipe"]["fast-inserter"].enabled = true
data.raw["recipe"]["filter-inserter"].enabled = true
data.raw["recipe"]["stack-inserter"].enabled = true
data.raw["recipe"]["stack-filter-inserter"].enabled = true