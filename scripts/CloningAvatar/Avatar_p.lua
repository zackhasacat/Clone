local I = require('openmw.interfaces')
local core = require('openmw.core')
local types = require('openmw.types')
local self = require('openmw.self')
local camera = require('openmw.camera')
local debug = require('openmw.debug')
local ui = require('openmw.ui')
local deadCamera = false
local AvatarSelect = require("scripts.CloningAvatar.omw.AvatarSelectionMenu")
local AvatarManage = require("scripts.CloningAvatar.omw.AvatarManageMenu")

local playerCurrentCloneType = "RealPlayer"
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
local  lastCell
local function onUpdate(dt)
    if self.type.stats.dynamic.health(self).current <= 1 then
        self.type.stats.dynamic.health(self).current = 100
        --types.Actor.resurrect(self)
        --  camera.setMode(camera.MODE.Static)
        setCollisionState(false)
        rezPlayer()
        deadCamera = true
    end
    if self.cell.name ~= lastCell then
        
        lastCell = self.cell.name
        core.sendGlobalEvent("CellChanged",self.cell.name)
    end
    if deadCamera == true and camera.getMode() == camera.MODE.ThirdPerson then
        camera.setMode(camera.MODE.Static)
        deadCamera = false
    end
end
local function onQuestUpdate(quid,stage)
    print(quid)
    core.sendGlobalEvent("Clone_QU",{questId = quid,stage = stage})

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
local function openCloneManageMenu(data)
    AvatarManage.showMessageBox(data)
end
local function onConsoleCommand(mode, command)
    core.sendGlobalEvent("onConsoleCommand", command)
end
local function onKeyPress(k)
    core.sendGlobalEvent("onKeyPress", k.symbol)
end
local function showMessage(msg)
    ui.showMessage(msg)
end
local function writeToConsole(msg)
    ui.printToConsole(msg, ui.CONSOLE_COLOR.Info)
end
local function closeMenu()

end
local function onSave()
    return { playerCurrentCloneType = playerCurrentCloneType }
end
local function onLoad(data)
    playerCurrentCloneType = data.playerCurrentCloneType
end
local function setplayerCurrentCloneType(state)
    playerCurrentCloneType = state
end
local function CA_SetStat(data)
    --  actorTarget:sendEvent("CA_SetStat",{stat = "skills",key = key, base = val(actorSource).base, damage = val(actorSource).damage,  modifier = val(actorSource).modifier})

    if data.base then
        self.type.stats[data.stat][data.key](self).base = data.base
        if self.type.stats[data.stat][data.key](self).current and self.type.stats[data.stat][data.key](self).current > data.base then
            self.type.stats[data.stat][data.key](self).current = data.base
        end
    end
    if data.damage then
        self.type.stats[data.stat][data.key](self).damage = data.damage
    end
    if data.modifier then
        self.type.stats[data.stat][data.key](self).modifier = data.modifier
    end
    if data.current then
        self.type.stats[data.stat][data.key](self).current = data.current
    end
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
        onSave = onSave,
        onLoad = onLoad,
        onQuestUpdate = onQuestUpdate,
    },
    eventHandlers  = {
        CA_setEquipment = CA_setEquipment,
        RegainControl = RegainControl,
        closeMenuWindow_Clone = closeMenuWindow_Clone,
        openClonePlayerMenu = openClonePlayerMenu,
        openCloneManageMenu = openCloneManageMenu,
        showMessage = showMessage,
        writeToConsole = writeToConsole,
        CA_SetStat = CA_SetStat,
    }
}
