local types = require('openmw.types')
local self = require('openmw.self')
local function CA_setEquipment(equip)
    types.Actor.setEquipment(self, equip)
end
local function CA_setHealth(num)

    self.type.stats.dynamic.health(self).current = num

end
return { eventHandlers = { CA_setHealth = CA_setHealth,CA_setEquipment = CA_setEquipment } }
