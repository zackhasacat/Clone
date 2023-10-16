local I = require('openmw.interfaces')
local core = require('openmw.core')
local types = require('openmw.types')
local self = require('openmw.self')
local camera = require('openmw.camera')
local debug = require('openmw.debug')
local ui = require('openmw.ui')
local deadCamera = false
local AvatarSelect = require("scripts.CloningAvatar.AvatarSelectionMenu")
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
local function openClonePlayerMenu(data)
    AvatarSelect.showMessageBox(data)
end
local function onConsoleCommand(mode,command)
core.sendGlobalEvent("onConsoleCommand",command)
end
local function onKeyPress(k)
core.sendGlobalEvent("onKeyPress",k.symbol)
end
local function showMessage(msg)
ui.showMessage(msg)
end
local function writeToConsole(msg)
ui.printToConsole(msg, ui.CONSOLE_COLOR.Info)
end
local function closeMenu()

end
return {
    interfaceName  = "CloningAvatars",
    interface      = {
        version = 1,

    },
    engineHandlers = {
        onUpdate = onUpdate,
        onConsoleCommand = onConsoleCommand,
        onKeyPress = onKeyPress,
    },
    eventHandlers  = {
        CA_setEquipment = CA_setEquipment,
        RegainControl = RegainControl,
        closeMenuWindow_Clone = closeMenuWindow_Clone,
        openClonePlayerMenu = openClonePlayerMenu,
        showMessage = showMessage,
        writeToConsole= writeToConsole,
    }
}