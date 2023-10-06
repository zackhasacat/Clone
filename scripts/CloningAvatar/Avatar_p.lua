local I = require('openmw.interfaces')
local core = require('openmw.core')
local types = require('openmw.types')
local self = require('openmw.self')
local camera = require('openmw.camera')
local debug = require('openmw.debug')
local deadCamera = false
local function CA_setEquipment(equip)
    types.Actor.setEquipment(self, equip)
end
local function rezPlayer()
core.sendGlobalEvent("playerRespawn")
end
local function setCollisionState(state)
    if debug.isCollisionEnabled() ~= state then
        debug.toggleCollision()
    end
end
local function onUpdate(dt)
if self.type.stats.dynamic.health(self).current <= 1 then
    self.type.stats.dynamic.health(self).current = 100
   --types.Actor.resurrect(self)
  --  camera.setMode(camera.MODE.Static)
   setCollisionState(false)
   rezPlayer()
   deadCamera = true
end
if deadCamera == true and camera.getMode() == camera.MODE.ThirdPerson then
    camera.setMode(camera.MODE.Static)
    deadCamera = false
end
end
local function RegainControl()

    camera.setMode(camera.MODE.FirstPerson)
    setCollisionState(true)
end
local function closeMenuWindow_Clone()
    I.UI.setMode()
end
return {
    interfaceName  = "CloningAvatars",
    interface      = {
        version = 1,

    },
    engineHandlers = {
        onUpdate = onUpdate,
    },
    eventHandlers  = {
        CA_setEquipment = CA_setEquipment,
        RegainControl = RegainControl,
        closeMenuWindow_Clone = closeMenuWindow_Clone
    }
}