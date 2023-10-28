local events     = {}

local pathPrefix = "VerticalityGangProject.scripts.CloningAvatar"

local omw, core  = pcall(require, "openmw.core")
if omw then
    pathPrefix = "scripts.CloningAvatar"
end
local cloneRoomManager = require(pathPrefix .. ".CloneRoomManager")
local commonUtil = require(pathPrefix .. ".common.commonUtil")
local dataManager = require(pathPrefix .. ".common.dataManager")
local cloneData = require(pathPrefix .. ".common.cloneData")
function events.onActivate(object, actor)
    local recId = commonUtil.getRefRecordId(object)
    if recId == "zhac_button_1" then --real body
        commonUtil.setObjectState("zhac_forcefield2", true)
        commonUtil.setObjectState("zhac_forcefield1", false)
        --  cloneData.transferPlayerData(commonUtil.getPlayer(), commonUtil.getReferenceById("player"), true)
        cloneData.savePlayerData()
        commonUtil.openCloneMenu(true)
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

function events.onQuestUpdate(id, stage)
    if id:lower() == "tdm_clone_mq" then
        if stage == 50 then
            dataManager.setValue("ZHAC_CloneRoomState",2)
        elseif stage == 60 then
            
            dataManager.setValue("ZHAC_CloneRoomState",3)
        elseif stage == 70 then
            
            dataManager.setValue("ZHAC_CloneRoomState",4)
        end
    end
end

function events.onKeyPress(keyChar)
    if keyChar == 'k' then
        if commonUtil.menuMode() then
            return
        end
        commonUtil.showMessage("K Pressed")
        commonUtil.openCloneMenu()
    end
end

function events.onPlayerDeath(player)
    cloneData.handleCloneDeath()
end

function events.onConsoleCommand(command)
    if command == "luaclonetp" or command == "clonetp" then
        commonUtil.teleportActor(commonUtil.getPlayer(), "gnisis, arvs-drelen", { x = 3870, y = 3857, z = 256 })
        commonUtil.writeToConsole("Teleported to Gnisis")
        commonUtil.closeMenu()
    end
end

return events
