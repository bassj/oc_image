local component = require("component")
local text = require("bassj.text")

local iface = component.me_interface

local items = iface.getItemsInNetwork({
    label = "Drone"
})

print(#items)

-- local allItems = iface.allItems()
--
-- local itemOne = allItems()
--
-- text.pprint(itemOne)
