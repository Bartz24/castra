function containsValue(array, value)
    if not value then
        return false
    end

    for _, v in ipairs(array) do
        if v == value then
            return true
        end
    end
    return false
end

function changeToCategory(item)
    for _, recipe in pairs(data.raw["recipe"]) do
        if recipe.results then
            for _, result in pairs(recipe.results) do
                if result.name == item.name then
                    if not recipe.category or recipe.category == "crafting" then
                        recipe.category = "castra-crafting"
                        break
                    elseif recipe.category == "chemistry" then
                        recipe.category = "castra-chemistry"
                        break
                    elseif recipe.category == "electromagnetics" then
                        recipe.category = "castra-electromagnetics"
                        break
                    end
                end
            end
        end
    end    
end

for _, item in pairs(data.raw["capsule"]) do
    if not item.subgroup or not containsValue(data.raw["item-subgroup"], item.subgroup) or data.raw["item-subgroup"][item.subgroup].group ~= "combat" then
        goto continueCapsule
    end
    changeToCategory(item)
    ::continueCapsule::
end

for _, item in pairs(data.raw["ammo"]) do
    changeToCategory(item)
end

for _, item in pairs(data.raw["gun"]) do
    changeToCategory(item)
end

for _, item in pairs(data.raw["armor"]) do
    changeToCategory(item)
end

for _, item in pairs(data.raw["item"]) do
    if not item.subgroup or not data.raw["item-subgroup"][item.subgroup] or data.raw["item-subgroup"][item.subgroup].group ~= "combat" then
        goto continueItem
    end
    if item.subgroup == "turret" or item.subgroup == "military-equipment" or item.subgroup == "defensive-structure" then
        changeToCategory(item)
    end
    ::continueItem::
end

changeToCategory(data.raw["tool"]["military-science-pack"])

-- Add the miliaary crafting category to anything that had the crafting category
table.insert(data.raw.character.character.crafting_categories, "castra-crafting")
table.insert(data.raw["god-controller"].default.crafting_categories, "castra-crafting")

-- Loop through assembling-machine entities and add the military crafting categories
for _, entity in pairs(data.raw["assembling-machine"]) do
    if entity.crafting_categories then
        -- Check if it has the "crafting" category or "chemistry" category
        if containsValue(entity.crafting_categories, "crafting") then
            table.insert(entity.crafting_categories, "castra-crafting")
        end
        if containsValue(entity.crafting_categories, "chemistry") then
            table.insert(entity.crafting_categories, "castra-chemistry")
        end
        if containsValue(entity.crafting_categories, "electromagnetics") then
            table.insert(entity.crafting_categories, "castra-electromagnetics")
        end
    end
end

table.insert(data.raw.lab["lab"].inputs, "battlefield-science-pack")

-- Add lithium battery to railgun and railgun turret
table.insert(data.raw["recipe"]["railgun"].ingredients, { type="item", name="lithium-battery", amount=5 })
table.insert(data.raw["recipe"]["railgun-turret"].ingredients, { type="item", name="lithium-battery", amount=20 })

-- Add lithium battery to the promethium-science-pack recipe
table.insert(data.raw["recipe"]["promethium-science-pack"].ingredients, { type="item", name="lithium-battery", amount=1 })

-- Replace steel with nickel in the flamethrower recipes
for _, recipe in pairs(data.raw["recipe"]) do
    if string.find(recipe.name, "flamethrower") and recipe.ingredients then
        for _, ingredient in pairs(recipe.ingredients) do
            if ingredient.name == "steel-plate" then
                ingredient.name = "nickel-plate"
            end
        end
    end
end

-- Replace battery-mk3-equipment supercapacitor with lithium battery
for _, recipe in pairs(data.raw["recipe"]) do
    if recipe.name == "battery-mk3-equipment" then
        for _, ingredient in pairs(recipe.ingredients) do
            if ingredient.name == "supercapacitor" then
                ingredient.name = "lithium-battery"
            end
        end
    end
end

if mods["planet-muluna"] then
    -- Nerf electric-engine-unit-from-carbon time to x3 since it overshadows the normal lubricant recipe castra uses
    local recipe = data.raw["recipe"]["electric-engine-unit-from-carbon"]
    if recipe then
        recipe.energy_required = recipe.energy_required * 3
    end
end