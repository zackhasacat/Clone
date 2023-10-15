local dataManager   = require("scripts.CloningAvatar.common.dataManager")
local omw, core     = pcall(require, "openmw.core")
local _, world      = pcall(require, "openmw.world")
local _, nearby     = pcall(require, "openmw.nearby")
local _, types      = pcall(require, "openmw.types")
local _, util      = pcall(require, "openmw.util")
local _, interfaces = pcall(require, "openmw.interfaces")
local omw           = true
local cloneData = {}
local commonUtil    = {
}
local function getPlayer()
    if omw and world then
        return world.players[1]
    elseif omw and nearby then
        return nearby.players[1]
    elseif not omw then
        return tes3.getReference("player")
    end
end
function commonUtil.getActorId(actor)
    if omw then
        return actor.id
    end
end

 function cloneData.transferPlayerData(actor1, actor2, doTP)
    local actor1id = commonUtil.getActorId(actor1)
    local actor2id = commonUtil.getActorId(actor2)
    local actor1CD = cloneData.getCloneDataForNPC(actor1)
    local actor2CD = cloneData.getCloneDataForNPC(actor2)
    if not actor1CD and actor1id == commonUtil.getActorId(getPlayer()) then
        
       cloneData.markActorAsClone(actor1, "RealPlayer")
    end
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
            local record = world.overrideRecord(ret,ret.id)
            return record
        else
            return types.NPC.record("ZHAC_AvatarBase")
        end
    end
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
 function commonUtil.createPlayerClone(cell, position, rotation)
    local newActor
    if omw then
        if position.x then
            position = util.vector3(position.x,position.y,position.z)
        end
        newActor = world.createObject(commonUtil.getCloneRecord().id)
        newActor:teleport(cell, position, rotation)
        return newActor
    end
end

function commonUtil.getReferenceById(id, locationData)
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
                cell = world.getExteriorCell(locationData.px, locationData.py, locationData.worldSpaceId)
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

 function cloneData.getCloneData()
    return dataManager.getValueOrTable("CloneData")
end
 function cloneData.setCloneData(data)
    dataManager.setValue("CloneData", data)
end
 function cloneData.getCloneDataForNPC(actor)
    local currentId = commonUtil.getActorId(actor)
    for index, value in pairs(cloneData.getCloneData()) do
        if value.currentId == currentId then
            return value
        end
    end
    return nil
end
 function cloneData.setCloneDataForNPCID(cloneID, newID,type)
    local cdata = cloneData.getCloneData()
    for index, value in pairs(cdata) do
        if value.id == cloneID then
            cdata[index].currentId = newID
        end
    end
    cloneData.setCloneData(cdata)
end
 function cloneData.updateClonedataLocation(actor)
    local currentId = commonUtil.getActorId(actor)
    local cdata = cloneData.getCloneData()
    for index, value in pairs(cdata) do
        if value.currentId == currentId then
            cdata[index].locationData = commonUtil.getLocationData(actor)
            return value
        end
    end
    cloneData.setCloneData(cdata)
    return nil
end
 function cloneData.getCloneObject(cloneId)
    local cdata = cloneData.getCloneData()
    for index, value in pairs(cdata) do
        if value.id == cloneId then
            return commonUtil.getReferenceById(value.currentId, value.locationData)
        end
    end
end
function cloneData.markActorAsClone(actor,type)


    local cdata = cloneData.getCloneData()
    local nextCloneId = dataManager.getValueOrInt("NextCloneId")+ 1
    local newCloneData = {}
    newCloneData.currentId = commonUtil.getActorId(actor)
    newCloneData.cloneType = "PlayerClone"
    if type ~= nil then
        newCloneData.cloneType = type
        newCloneData.name = types.NPC.record("player").name
    else
        
    newCloneData.name = "Clone " ..nextCloneId
    end
    newCloneData.id = nextCloneId
    dataManager.setValue("NextCloneId", nextCloneId )
    cdata[nextCloneId] = newCloneData
    cloneData.setCloneData(cdata)
    return { cloneData = cdata, createdCloneId = nextCloneId, newClone = actor }
end
 function cloneData.addCloneToWorld(cell, position, rotation,cloneType)
    local newClone = commonUtil.createPlayerClone(cell, position, rotation)
    local data = cloneData.markActorAsClone(newClone,cloneType)
    return { cloneData = data.cloneData, createdCloneId = data.createdCloneId, newClone = newClone }
end
 function cloneData.storePlayer()

    local cdata = cloneData.getCloneData()
    local player = getPlayer()
    
    for index, value in pairs(cdata) do
        if value.cloneType == "RealPlayer" then
            error("Player already exists")
        end
    end
    local newClone = cloneData.addCloneToWorld(player.cell,player.position,nil,"RealPlayer")
    commonUtil.transferPlayerData(player,newClone)
end
return cloneData