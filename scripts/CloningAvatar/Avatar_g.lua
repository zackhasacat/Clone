local types = require("openmw.types")
local world = require("openmw.world")
local acti = require("openmw.interfaces").Activation
local core = require("openmw.core")
local util = require("openmw.util")
local I = require("openmw.interfaces")
local async = require('openmw.async')
local storage = require("openmw.storage")
local actorSwap = require('scripts.CloningAvatar.ActorSwap')
local function doActorSwap(data)
    actorSwap.doActorSwap(data.actor1, data.actor2)
end
local function createPlayerAvatar(player)
    local playerRecord = types.NPC.record(player)
    local rec = {
        name = playerRecord.name,
        template = types.NPC.record("ZHAC_AvatarBase"),
        isMale = playerRecord.isMale,
        head = playerRecord.head,
        hair = playerRecord.hair,
        class = playerRecord.class,
        race = playerRecord.race
    }
    local ret = types.NPC.createRecordDraft(rec)
    local record = world.overrideRecord(ret)
    local newActor = world.createObject(record.id)
    newActor:teleport(player.cell, player.position)
    return newActor
end
local function rezPlayer()
    local scr = world.mwscript.getGlobalScript("ZHAC_PlayerRez", world.players[1])
    scr.variables.doRez = 1
end
local respawnCell = "Caldera, Guild of Mages"
local respawnPos = util.vector3(521.4033203125, 882.4403076171875, 401)
local function movePlayerToNewBody()
    local player = world.players[1]
    player:setScale(1)
    player:teleport(respawnCell, respawnPos)
    player:sendEvent("RegainControl")
end
local function playerRespawn()
    local player = world.players[1]
    rezPlayer()
    player:setScale(0.001)
    local deadAvatar = createPlayerAvatar(player)
    actorSwap.doActorSwap(player, deadAvatar, false)
    deadAvatar:sendEvent("CA_setHealth", 0)
    player:teleport(player.cell, util.vector3(player.position.x, player.position.y, player.position.z + 1000))
    async:newUnsavableSimulationTimer(5, movePlayerToNewBody)
end
local activatedActor
local function activateNPC(object, actor)
   --print(object.recordId)
    if object.recordId == "zhac_avatarbase" then
        --actorSwap.doActorSwap(actor, object)
        --return false
        activatedActor = object
    end
end
local function onItemActive(item)
    if item.recordId == "zhac_swapmarker" then
        item:remove()
        if activatedActor then
            actorSwap.doActorSwap(world.players[1], activatedActor)
            world.players[1]:sendEvent("closeMenuWindow_Clone")
        end
    end
end
acti.addHandlerForType(types.NPC, activateNPC)
return {
    interfaceName  = "CloningAvatars",
    interface      = {
        version = 1,

    },
    engineHandlers = {
        onItemActive = onItemActive
    },
    eventHandlers  = {
        doActorSwap = doActorSwap,
        createPlayerAvatar = createPlayerAvatar,
        rezPlayer = rezPlayer,
        playerRespawn = playerRespawn,
    }
}
