local pathPrefix    = "VerticalityGangProject.scripts.CloningAvatar"
local omw, core     = pcall(require, "openmw.core")
local _, world      = pcall(require, "openmw.world")
local _, nearby     = pcall(require, "openmw.nearby")
local _, types      = pcall(require, "openmw.types")
local _, util       = pcall(require, "openmw.util")
local _, interfaces = pcall(require, "openmw.interfaces")
if omw then
    pathPrefix = "scripts.CloningAvatar"
end
local dataManager = require(pathPrefix .. ".common.dataManager")
local cloneData   = {}
local commonUtil  = {
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
    else
        return actor.id
    end
end

local actor1Saved
local actor2Saved
local actor1EquipSaved = {}
local actor2EquipSaved = {}
local actor2DestCell
local actor2DestPos
local actor2DestRot
function cloneData.transferPlayerData(actor1, actor2, doTP)
     actor1Saved = actor1
     actor2Saved = actor2
     actor1EquipSaved = {}
     actor2EquipSaved = {}
    local actor1id = commonUtil.getActorId(actor1)
    local actor2id = commonUtil.getActorId(actor2)
    local actor1CD = cloneData.getCloneDataForNPC(actor1)
    local actor2CD = cloneData.getCloneDataForNPC(actor2)
    if not actor1CD and actor1id == commonUtil.getActorId(getPlayer()) then
        print("Saved player data")
        cloneData.markActorAsClone(actor1, "RealPlayer")
        actor1CD = cloneData.getCloneDataForNPC(actor1)
    end
    if actor1CD and actor2CD then
        cloneData.setCloneDataForNPCID(actor1CD.id, actor2id)
        cloneData.setCloneDataForNPCID(actor2CD.id, actor1id)
    else
        error("Missing data")
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
        cloneData.updateClonedataLocation(actor1, actor2)
        cloneData.updateClonedataLocation(actor2, actor1)
    else
        local actor1pos = actor1.position:copy()
        local actor1cell = actor1.cell.name
        local actor1rot = actor1.orientation:copy()

        local actor2pos = actor2.position:copy()
        local actor2cell = actor2.cell.name
        local actor2rot = actor2.orientation:copy()
        actor2DestCell = actor2cell
        actor2DestPos = actor2pos
        actor2DestRot = actor2rot
        local tp1 = tes3.positionCell({
            reference = actor2,
            position = actor1pos,
            cell = actor1cell,
            orientation = actor1rot,
            teleportCompanions = false
        })
        local actor1Inv = {}
        local actor2Inv = {}
        for index, item in ipairs(actor1.mobile.inventory) do
            table.insert(actor1Inv, item)
        end
        for index, item in ipairs(actor2.mobile.inventory) do
            table.insert(actor2Inv, item)
        end
        for index, item in ipairs(actor1Inv) do
            local objectId = item.object.id
            local equipped = actor1.object:hasItemEquipped(objectId)
            if equipped then
                actor2EquipSaved[objectId] = true
                actor1.mobile:unequip({ item =  objectId, playSound = false })
            end
            tes3.transferItem({
                from                = actor1.mobile,
                item                = item.object,
                to                  = actor2.mobile,
                count               = item.count,
                playSound           = false,
                reevaluateEquipment = false,
            })
        end
        for index, item in ipairs(actor2Inv) do
            local objectId = item.object.id
            local equipped = actor2.object:hasItemEquipped(objectId)
            if equipped then
                actor1EquipSaved[objectId] = true
                actor2.mobile:unequip({ item =  objectId, playSound = false })
            end
            tes3.transferItem({
                from                = actor2.mobile,
                item                = item.object,
                to                  = actor1.mobile,
                count               = item.count,
                playSound           = false,
                reevaluateEquipment = false,
            })
        end
        if doTP ~= false then
            tes3.fadeOut({ duration = 0.0001 })
            if not tp1 then
                error("Actor2 not TP")
            end
            local function onTimerComplete()
                for index, item in ipairs(actor1Saved.mobile.inventory) do
                    local objectId = item.object.id
                    if actor1EquipSaved[objectId] then
                        actor1Saved.mobile:equip({ item = objectId, playSound = false })
                        print("Equipped ".. objectId)
                    end
                end
                for index, item in ipairs(actor2Saved.mobile.inventory) do
                    local objectId = item.object.id
                    if actor2EquipSaved[objectId] then
                        actor2Saved.mobile:equip({ item = objectId, playSound = false })
                        print("Equipped ".. objectId)
                    end
                end
                local tp2 = tes3.positionCell({
                    reference = actor1Saved,
                    position = actor2DestPos,
                    cell = actor2DestCell,
                    orientation = actor2DestRot,
                    teleportCompanions = false
                })
    
                tes3.fadeIn({ duration = 1 })
            end

            -- Create our timer to fire the above function after 30 seconds.
            timer.start({ duration = 1, callback = onTimerComplete })
        end
    end
end

function cloneData.getCloneRecord()
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
    else
        local cloneRecord = tes3.getObject("ZHAC_AvatarBase")
        local playerRecord = tes3.getObject("player")
        cloneRecord.hair = playerRecord.hair
        cloneRecord.race = playerRecord.race
        cloneRecord.name = playerRecord.name
        cloneRecord.female = playerRecord.female
        cloneRecord.class = playerRecord.class
        cloneRecord.head = playerRecord.head
        cloneRecord.modified = true
        return cloneRecord
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
            position = util.vector3(position.x, position.y, position.z)
        end
        newActor = world.createObject(cloneData.getCloneRecord().id)
        newActor:teleport(cell, position, rotation)
        return newActor
    else
        if not rotation then
            rotation = tes3vector3.new(0, 0, 0)
        end
        position = tes3vector3.new(position.x, position.y, position.z)
        newActor = tes3.createReference({
            object = cloneData.getCloneRecord(),
            position = position,
            cell = cell,
            orientation = rotation
        })
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
            if locationData.exterior == true then
                print("Found Exterior")
                cell = world.getExteriorCell(locationData.px, locationData.py)
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

function cloneData.setCloneDataForNPCID(cloneID, newID, type)
    local cdata = cloneData.getCloneData()
    for index, value in pairs(cdata) do
        if value.id == cloneID then
            cdata[index].currentId = newID
        end
    end
    cloneData.setCloneData(cdata)
end

function cloneData.updateClonedataLocation(actor, tempActor)
    local currentId = commonUtil.getActorId(actor)
    local cdata = cloneData.getCloneData()
    if not tempActor then
        tempActor = actor
    end
    for index, value in pairs(cdata) do
        if value.currentId == currentId then
            cdata[index].locationData = commonUtil.getLocationData(tempActor)
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
            local ref = commonUtil.getReferenceById(value.currentId, value.locationData)
            if not ref then
                error("Could not find actor " .. value.currentId .. value.locationData.cell)
            end
            return ref
        end
    end
end

function cloneData.markActorAsClone(actor, type)
    local playerName
    if omw then
        playerName = types.NPC.record("player").name
    else
        playerName = tes3.player.object.name
    end
    local cdata = cloneData.getCloneData()
    local nextCloneId = dataManager.getValueOrInt("NextCloneId") + 1
    local newCloneData = {}
    newCloneData.currentId = commonUtil.getActorId(actor)
    newCloneData.cloneType = "PlayerClone"
    if type ~= nil then
        newCloneData.cloneType = type
        newCloneData.name = playerName
    else
        newCloneData.name = "Clone " .. nextCloneId
    end
    newCloneData.id = nextCloneId
    dataManager.setValue("NextCloneId", nextCloneId)
    cdata[nextCloneId] = newCloneData
    cloneData.setCloneData(cdata)
    return { cloneData = cdata, createdCloneId = nextCloneId, newClone = actor }
end

function cloneData.addCloneToWorld(cell, position, rotation, cloneType)
    local newClone = commonUtil.createPlayerClone(cell, position, rotation)
    local data = cloneData.markActorAsClone(newClone, cloneType)
    return { cloneData = data.cloneData, createdCloneId = data.createdCloneId, newClone = newClone }
end

function commonUtil.getCellName(actor)
    if not omw then
        return actor.mobile.cell.name
    else
        if actor.cell.name == "" and actor.cell.isExterior then
            return actor.cell.region
        end
        return actor.cell.name
    end
end

function commonUtil.getActorHealth(actor)
    if omw then
        return types.Actor.stats.dynamic.health(actor).current
    else
        return actor.mobile.health.current
    end
end

function cloneData.getMenuData()
    local cdata = cloneData.getCloneData()
    local menuData = {}

    for index, value in pairs(cdata) do
        local newData = { id = value.id, name = value.name, info = {} }
        local actor = cloneData.getCloneObject(value.id)
        if not actor then
            error("Couldn't find actor " .. value.id)
        end
        newData.info["loc"] = "Current Location: " .. commonUtil.getCellName(actor)
        newData.info["health"] = "Health: " .. tostring(commonUtil.getActorHealth(actor))
        newData.realId = commonUtil.getActorId(actor)
        table.insert(menuData, newData)
    end
    return menuData
end

function cloneData.storePlayer()
    local cdata = cloneData.getCloneData()
    local player = getPlayer()

    for index, value in pairs(cdata) do
        if value.cloneType == "RealPlayer" then
            error("Player already exists")
        end
    end
    local newClone = cloneData.addCloneToWorld(player.cell, player.position, nil, "RealPlayer")
    commonUtil.transferPlayerData(player, newClone)
end

return cloneData
