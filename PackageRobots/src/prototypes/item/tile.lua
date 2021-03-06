data:extend(
{
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
      result = "concrete-path-n",
      condition_size = 1,
      condition = { "water-tile" }
    }
  },
  {
    type = "item",
    name = "concrete-path-i",
    icon = "__PackageRobots__/graphics/icons/concrete-path-i.png",
    icon_size = 32,
    flags = {"goes-to-quickbar"},
    subgroup = "logistic-network",
    order = "p[concrete]-a[plain]",
    stack_size = 100,
    place_as_tile =
    {
      result = "concrete-path-j",
      condition_size = 1,
      condition = { "water-tile" }
    }
  },
  {
    type = "item",
    name = "concrete-path-c",
    icon = "__PackageRobots__/graphics/icons/concrete-path-c.png",
    icon_size = 32,
    flags = {"goes-to-quickbar"},
    subgroup = "logistic-network",
    order = "p[concrete]-a[plain]",
    stack_size = 100,
    place_as_tile =
    {
      result = "concrete-path-p",
      condition_size = 1,
      condition = { "water-tile" }
    }
  }
})  