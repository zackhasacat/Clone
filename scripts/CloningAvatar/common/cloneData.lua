local commonUtil = require("scripts.CloningAvatar.common.commonUtil")
local dataManager = require("scripts.CloningAvatar.common.dataManager")
local function getCloneData()
    return dataManager.getValueOrTable("CloneData")
end
local function setCloneData(data)
    dataManager.setValue("CloneData", data)
end
local function getCloneDataForNPC(actor)
    local currentId = commonUtil.getActorId(actor)
    for index, value in pairs(getCloneData()) do
        if value.currentId == currentId then
            return value
        end
    end
    return nil
end
local function setCloneDataForNPCID(cloneID, newID)
    local cdata = getCloneData()
    for index, value in pairs(cdata) do
        if value.id == cloneID then
            cdata[index].currentId = newID
        end
    end
    setCloneData(cdata)
end
local function updateClonedataLocation(actor)
    local currentId = commonUtil.getActorId(actor)
    local cdata = getCloneData()
    for index, value in pairs(cdata) do
        if value.currentId == currentId then
            cdata[index].locationData = commonUtil.getLocationData(actor)
            return value
        end
    end
    setCloneData(cdata)
    return nil
end
local function getCloneObject(cloneId)
    local cdata = getCloneData()
    for index, value in pairs(cdata) do
        if value.id == cloneId then
            return commonUtil.getReferenceById(value.currentId,value.locationData)
        end
    end
end
local function addCloneToWorld(cell, position, rotation)
    local cdata = getCloneData()
    local nextCloneId = dataManager.getValueOrInt("NextCloneId")
    local newCloneData = {}
    local newClone = commonUtil.createPlayerClone(cell, position, rotation)
    newCloneData.currentId = commonUtil.getActorId(newClone)
    newCloneData.cloneType = "PlayerClone"
    newCloneData.id = nextCloneId
    dataManager.setValue("NextCloneId", nextCloneId + 1)
    cdata[nextCloneId] = newCloneData
    setCloneData(cdata)
    return { cloneData = cdata, createdCloneId = nextCloneId, newClone = newClone }
end
return { getCloneData = getCloneData, setCloneData = setCloneData, addCloneToWorld = addCloneToWorld,
    getCloneDataForNPC = getCloneDataForNPC, setCloneDataForNPCID = setCloneDataForNPCID,
    updateClonedataLocation = updateClonedataLocation, getCloneObject = getCloneObject }
