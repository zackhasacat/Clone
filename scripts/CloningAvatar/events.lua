local events = {}

local commonUtil = require("scripts.CloningAvatar.common.commonUtil")
local dataManager = require("scripts.CloningAvatar.common.dataManager")
local cloneData = require("scripts.CloningAvatar.common.cloneData")
function events.onActivate(object, actor)
    local recId = commonUtil.getRefRecordId(object)
    if recId == "zhac_button_1" then --real body
        commonUtil.setObjectState("zhac_forcefield2", true)
        commonUtil.setObjectState("zhac_forcefield1", false)
        cloneData.transferPlayerData(commonUtil.getPlayer(), commonUtil.getReferenceById("zhac_avatarbase"))
    elseif recId == "zhac_button_2" then 
        local newClone = cloneData.addCloneToWorld("gnisis, arvs-drelen", { x = 3977, y = 3286, z = 256 })
      --  cloneData.transferPlayerData(commonUtil.getPlayer(),newClone.newClone,false)
    end
end

function events.onInit()
    local gameStarted = dataManager.getValue("gameStarted", false)
    if not gameStarted then
        cloneData.addCloneToWorld("gnisis, arvs-drelen", { x = 3977, y = 3286, z = 256 })
        dataManager.setValue("gameStarted", true)
    end
end
function events.onKeyPress(keyChar)
if keyChar == 'k' then
    commonUtil.openCloneMenu()
end

end

function events.onConsoleCommand(command)
    if command == "luaclonetp" or command == "clonetp" then
        commonUtil.teleportActor(commonUtil.getPlayer(), "gnisis, arvs-drelen", { x = 3870, y = 3857, z = 256 })
    end
end

return events
