local dataManager = {}
function dataManager.setValue(valueName, value)
    tes3.player.data[valueName] = value
end

function dataManager.getValue(valueName,default)
    
    local val =  tes3.player.data[valueName]
    if not val and default then
        return default
    end
    return  val
end

local function getNextIDToUse()
local nextVal = dataManager.getValue("npcIDStage",0) + 1
dataManager.setValue("npcIDStage",nextVal)
local NPCID = "zhac_clonenpc_" .. string.format("%04d",nextVal)
return NPCID
end
local function createNPCClone(sourceRecord)
    local newRecord = getNextIDToUse()
    local cloneRecord = tes3.getObject(newRecord)
        cloneRecord.hair = sourceRecord.hair
        cloneRecord.race = sourceRecord.race
        cloneRecord.female = sourceRecord.female
        cloneRecord.class = sourceRecord.class
        cloneRecord.head = sourceRecord.head
        cloneRecord.name = "Clone of " ..sourceRecord.name
        cloneRecord.modified = true
        local rotation = tes3vector3.new(0, 0, math.rad(-90))
        local position = tes3.player.position
        position = tes3vector3.new(position.x, position.y, position.z)
        local newActor = tes3.createReference({
            object = tes3.getObject(newRecord),
            position = position,
            cell = tes3.player.cell,
            orientation = rotation
        })
        return cloneRecord
    
end
return{getNextIDToUse = getNextIDToUse, createNPCClone = createNPCClone}