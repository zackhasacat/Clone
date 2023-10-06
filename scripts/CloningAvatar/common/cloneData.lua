
local cloneData = {}

local function getCloneData()
return cloneData
end
local function setCloneData(data)
cloneData = data
end
return{getCloneData = getCloneData,setCloneData = setCloneData}