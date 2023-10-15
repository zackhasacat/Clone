local omw, core     = pcall(require, "openmw.core")
local _, world      = pcall(require, "openmw.world")
local _, nearby     = pcall(require, "openmw.nearby")
local _, types      = pcall(require, "openmw.types")
local _, interfaces = pcall(require, "openmw.interfaces")
local _, util       = pcall(require, "openmw.util")
local cloneData     = require("scripts.CloningAvatar.common.cloneData")
local commonUtil    = {}
function commonUtil.getPlayer()
    print(omw, world == nil)
    if omw and world then
        return world.players[1]
    elseif omw and nearby then
        return nearby.players[1]
    elseif not omw then
        return tes3.getReference("player")
    end
end

function commonUtil.getReferenceById(id, locationData)
    if omw and world then
        if id == commonUtil.getPlayer().id then
            return commonUtil.getPlayer()
        end
        if not locationData then
            for index, value in ipairs(world.activeActors) do
                if value.id == id or value.recordId == id:lower() then
                    return value
                end
            end
        else
            local cell
            if locationData.cell.name ~= nil then
                cell = locationData.cell
            elseif locationData.exterior then
                cell = world.getExteriorCell(locationData.px, locationData.py, locationData.worldSpaceId)
            else
                cell = world.getCellByName(locationData.cell)
            end
            for index, value in ipairs(cell:getAll()) do
                if value.id == id or value.recordId == id:lower() then
                    return value
                end
            end
        end
    elseif omw and nearby then
        if id == commonUtil.getPlayer().id then
            return commonUtil.getPlayer()
        end
        for index, value in ipairs(nearby.actors) do
            if value.id == id then
                return value
            end
        end
    elseif not omw then
        return tes3.getReference(id)
    end
end

function commonUtil.getActorId(actor)
    if omw then
        return actor.id
    end
end

function commonUtil.getRefRecordId(obj)
    if omw then
        return obj.recordId:lower()
    end
end

local function handlePlayerDeath()

end
function commonUtil.getLocationData(obj)
    if omw then
        return {
            exterior = obj.cell.isExterior,
            cell = obj.cell.name,
            px = obj.cell.gridX,
            py = obj.cell.gridY,
            position = obj.position,
            rotation = obj.rotation,
            worldSpaceId = obj.cell.worldSpaceId
        }
    end
end

function commonUtil.getCloneRecord()
    if omw then
        local playerRecord = types.NPC.record(getPlayer())
        local rec = {
            name = playerRecord.name,
            template = types.NPC.record("ZHAC_AvatarBase"),
            isMale = playerRecord.isMale,
            head = playerRecord.head,
            hair = playerRecord.hair,
            class = playerRecord.class,
            race = playerRecord.race
        }
        if types.NPC.createRecordDraft then
            local ret = types.NPC.createRecordDraft(rec)
            local record = world.overrideRecord(ret, ret.id)
            return record
        else
            return types.NPC.record("ZHAC_AvatarBase")
        end
    end
end

function commonUtil.setObjectState(id, state)
    local obj = commonUtil.getReferenceById(id, { cell = commonUtil.getPlayer().cell })
    if omw then
        obj.enabled = state
    end
end

function commonUtil.setActorHealth(actor, health)
    if omw then
        actor:sendEvent("CA_setHealth", health)
    end
end

function commonUtil.createPlayerClone(cell, position, rotation)
    local newActor
    if omw then
        if position.x then
            position = util.vector3(position.x, position.y, position.z)
        end
        newActor = world.createObject(getCloneRecord().id)
        newActor:teleport(cell, position, rotation)
        return newActor
    end
end

function commonUtil.teleportActor(actor, cellName, pos)
    if omw then
        actor:teleport(cellName, util.vector3(pos.x, pos.y, pos.z))
    end
end

function commonUtil.openCloneMenu()
    if omw then
        core.sendGlobalEvent("openClonePlayerMenu")
    end
end

return commonUtil
