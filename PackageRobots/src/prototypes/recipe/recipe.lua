data:extend(
{
  {
    type = "recipe",
    name = "land-robot",
    enabled = true,
    energy_required = 1,
    ingredients =
    {
      {"engine-unit", 1},
      {"advanced-circuit", 3},
      {"iron-plate", 4},
      {"iron-gear-wheel", 2}
    },
    result = "land-robot"
  },
  {
    type = "recipe",
    name = "concrete-path",
    enabled = true,
    energy_required = 1,
    ingredients =
    {
      {"concrete", 10},
      {"copper-cable", 10}
    },
    result = "concrete-path",
    result_count = 10;
  },
  {
    type = "recipe",
    name = "concrete-path-i",
    enabled = true,
    energy_required = 1,
    ingredients =
    {
      {"concrete", 10},
      {"copper-cable", 10},
      {"electronic-circuit", 10}
    },
    result = "concrete-path-i",
    result_count = 10;
  },
  {
    type = "recipe",
    name = "concrete-path-c",
    enabled = true,
    energy_required = 1,
    ingredients =
    {
      {"concrete", 10},
      {"copper-cable", 10},
      {"electronic-circuit", 20}
    },
    result = "concrete-path-c",
    result_count = 10;
  },
  {
    type = "recipe",
    name = "resource-drop",
    enabled = true,
    energy_required = 1,
    ingredients =
    {
      {"steel-chest", 1},
      {"advanced-circuit", 1}
    },
    result = "resource-drop",
    result_count = 1;
  },
  {
    type = "recipe",
    name = "resource-pickup",
    enabled = true,
    energy_required = 1,
    ingredients =
    {
      {"stack-inserter", 1},
      {"advanced-circuit", 1}
    },
    result = "resource-pickup",
    result_count = 1;
  }
})  