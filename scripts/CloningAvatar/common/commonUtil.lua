local omw, core     = pcall(require, "openmw.core")
local _, world      = pcall(require, "openmw.world")
local _, nearby     = pcall(require, "openmw.nearby")
local _, types      = pcall(require, "openmw.types")
local _, interfaces = pcall(require, "openmw.interfaces")
local cloneData     = require("scripts.CloningAvatar.common.cloneData")
local function getPlayer()
    if omw and world then
        return world.players[1]
    elseif omw and nearby then
        return nearby.players[1]
    elseif not omw then
        return tes3.getReference("player")
    end
end
local function getReferenceById(id, locationData)
    if omw and world then
        if id == getPlayer().id then
            return getPlayer()
        end
        if not locationData then
            for index, value in ipairs(world.activeActors) do
                if value.id == id then
                    return value
                end
            end
        else
            local cell
            if locationData.exterior then
                cell = world.getExteriorCell(locationData.px, locationData.py,locationData.worldSpaceId)
            else
                cell = world.getCellByName(locationData.cell)
            end
            for index, value in ipairs(cell:getAll(types.NPC)) do
                if value.id == id then
                    return value
                end
            end
        end
    elseif omw and nearby then
        if id == getPlayer().id then
            return getPlayer()
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
local function getActorId(actor)
    if omw then
        return actor.id
    end
end

local function transferPlayerData(actor1, actor2, doTP)
    local actor1id = getActorId(actor1)
    local actor2id = getActorId(actor2)
    local actor1CD = cloneData.getCloneDataForNPC(actor1)
    local actor2CD = cloneData.getCloneDataForNPC(actor2)
    if actor1CD and actor2CD then
        cloneData.setCloneDataForNPCID(actor1CD.id, actor2id)
        cloneData.setCloneDataForNPCID(actor2CD.id, actor1id)
    end
    if omw then
        local actor1Inv = {}
        local actor2Inv = {}
        local actor1Equip = types.Actor.getEquipment(actor1)
        local actor2Equip = types.Actor.getEquipment(actor2)

        for index, item in ipairs(types.Actor.inventory(actor1):getAll()) do
            table.insert(actor1Inv, item)
        end
        for index, item in ipairs(types.Actor.inventory(actor2):getAll()) do
            table.insert(actor2Inv, item)
        end
        for index, item in ipairs(actor1Inv) do
            item:moveInto(actor2)
        end
        for index, item in ipairs(actor2Inv) do
            item:moveInto(actor1)
        end
        actor1:sendEvent("CA_setEquipment", actor2Equip)
        actor2:sendEvent("CA_setEquipment", actor1Equip)
        if doTP ~= false then
            local actor1pos = actor1.position
            local actor1cell = actor1.cell
            local actor1rot = actor1.rotation
            local actor2pos = actor2.position
            local actor2cell = actor2.cell
            local actor2rot = actor2.rotation
            if actor2cell ~= nil then
                actor1:teleport(actor2cell, actor2pos, actor2rot)
            end
            actor2:teleport(actor1cell, actor1pos, actor1rot)
        end
    end
    cloneData.updateClonedataLocation(actor1)
    cloneData.updateClonedataLocation(actor2)
end
local function handlePlayerDeath()

end
local function getLocationData(obj)
    if omw then
        return { exterior = obj.cell.isExterior, cell = obj.cell.name, px = obj.cell.gridX, py = obj.cell.gridY,
            position = obj.position, rotation = obj.rotation, worldSpaceId = obj.cell.worldSpaceId }
    end
end
local function getCloneRecord()
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
        local ret = types.NPC.createRecordDraft(rec)
        local record = world.overrideRecord(ret)
        return record
    end
end
local function createPlayerClone(cell, position, rotation)
    local newActor
    if omw then
        newActor = world.createObject(getCloneRecord().id)
        newActor:teleport(cell, position, rotation)
        return newActor
    end
end


return {
    getPlayer = getPlayer,
    transferPlayerData = transferPlayerData,
    getReferenceById = getReferenceById,
    createPlayerClone = createPlayerClone,
    getCloneRecord = getCloneRecord,
    getActorId = getActorId,
    getLocationData = getLocationData,
}
