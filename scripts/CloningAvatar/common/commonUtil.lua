local omw, core     = pcall(require, "openmw.core")
local _, world      = pcall(require, "openmw.world")
local _, nearby     = pcall(require, "openmw.nearby")
local _, types      = pcall(require, "openmw.types")
local _, interfaces = pcall(require, "openmw.interfaces")
local _, util       = pcall(require, "openmw.util")

local cloneMenu
local cloneManageMenu
local pathPrefix    = "VerticalityGangProject.scripts.CloningAvatar"

if omw then
    pathPrefix = "scripts.CloningAvatar"
end
local cloneData   = require(pathPrefix .. ".common.cloneData")
local dataManager = require(pathPrefix .. ".common.dataManager")
--cutil = require("VerticalityGangProject.scripts.CloningAvatar.common.commonUtil")
local commonUtil  = {}
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

function commonUtil.getValueForRef(ref, valueId)
    if not omw then
        return ref.data[valueId]
    else
        return dataManager.getValue(ref.id .. valueId)
    end
end

function commonUtil.setValueForRef(ref, valueId, value)
    if not omw then
        ref.modified = true
        ref.data[valueId] = value
    else
        return dataManager.setValue(ref.id .. valueId, value)
    end
end

function commonUtil.setPosition(ref, position)
    if not omw then
        ref.position = position
    else
        ref:teleport(ref.cell, position)
    end
end

function commonUtil.getPosition(x, y, z)
    if not omw then
        return tes3vector3.new(x, y, z)
    else
        return util.vector3(x, y, z)
    end
end

function commonUtil.getObjectsInCell(cellOrCellname)
    if (not omw) then
        local cell = cellOrCellname
        if (cell.id == nil) then cell = ZackBridge.getCell(cell) end
        local refs = {}
        for ref in cell:iterateReferences() do
            table.insert(refs, ref)
        end
        return refs
    end
    local cell = cellOrCellname
    if (cell.name == nil) then
        cell = world.getCellByName(cell)
    else
        cell = cellOrCellname
    end
    return cell:getAll()
end

function commonUtil.getReferenceModId(ref)
    if omw then
        if not ref.contentFile then return nil end
        return ref.contentFile:lower()
    else
        if not ref.sourceMod then return nil end
        return ref.sourceMod:lower()
    end
end

function commonUtil.menuMode()
    if omw then
        return core.isWorldPaused()
    else
        return tes3.menuMode()
    end
end

function commonUtil.playerIsInClone()
    return cloneData.playerIsInClone()
end

if not omw then
    cloneMenu = include(pathPrefix .. ".mwse.cloneMenu")
    cloneManageMenu = include(pathPrefix .. ".mwse.cloneTubeMenu")
end
function commonUtil.openCloneMenu(force)
    local canOpen = cloneData.playerIsInClone()
    if not canOpen and not force then
        return
    end
    if omw then
        core.sendGlobalEvent("openClonePlayerMenu")
    else
        cloneMenu.createWindow()
    end
end

function commonUtil.openManageCloneMenu(id)
    if omw then
        --  core.sendGlobalEvent("openClonePlayerMenu")
    else
        cloneManageMenu.createWindow(id)
    end
end

function commonUtil.resurrectPlayer()
    commonUtil.setActorHealth(tes3.player.mobile, 100)
    if not omw then
        tes3.player.mobile:resurrect({ resetState = false, })
    end
    commonUtil.showMessage("Rezurrect time")
end

function commonUtil.getReferenceById(id, locationData)
    if omw and world then
        if id == commonUtil.getPlayer().id then
            return commonUtil.getPlayer()
        end
        if not locationData then
            for index, value in ipairs(world.activeActors) do
                if value.id == id or value.recordId == id:lower() and value ~= commonUtil.getPlayer() then
                    return value
                end
            end
            for index, value in ipairs(commonUtil.getPlayer().cell:getAll(types.Activator)) do
                if value.id == id or value.recordId == id:lower() and value ~= commonUtil.getPlayer() then
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
                if value.id == id or value.recordId == id:lower() and value ~= commonUtil.getPlayer() then
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
    else
        return actor.id
    end
end

function commonUtil.getRefRecordId(obj)
    if omw then
        return obj.recordId:lower()
    else
        return obj.baseObject.id:lower()
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
            worldSpaceId = obj.cell.worldSpaceId,
            region = obj.cell.region
        }
    end
end

function commonUtil.setObjectState(id, state)
    local obj = commonUtil.getReferenceById(id, { cell = commonUtil.getPlayer().cell })
    if omw then
        obj.enabled = state
    else
        tes3.setEnabled({ reference = obj, enabled = state })
    end
end

function commonUtil.setReferenceState(obj, state)
    if omw and obj.count > 0 then
        obj.enabled = state
    elseif not omw then
        tes3.setEnabled({ reference = obj, enabled = state })
    end
end

function commonUtil.setActorHealth(actor, health)
    if omw then
        actor:sendEvent("CA_setHealth", health)
    else
        actor.health.current = health
    end
end

function commonUtil.getScriptVariables(objectId, scriptName,val)
    local object = commonUtil.getReferenceById(objectId)
    if omw then
        return world.mwscript.getLocalScript(object).variables[val]
    else
        return object.context[val]
    end
end

function commonUtil.teleportActor(actor, cellName, pos)
    if omw then
        actor:teleport(cellName, util.vector3(pos.x, pos.y, pos.z))
    else
        tes3.positionCell({ reference = actor, cell = cellName, position = tes3vector3.new(pos.x, pos.y, pos.z) })
    end
end

function commonUtil.showMessage(msg)
    if omw then
        world.players[1]:sendEvent("showMessage", msg)
    else
        tes3ui.showNotifyMenu(msg)
    end
end

function commonUtil.writeToConsole(msg)
    if omw then
        world.players[1]:sendEvent("writeToConsole", msg)
    else
        tes3ui.log(msg)
    end
end

function commonUtil.closeMenu()
    if omw then
        world.players[1]:sendEvent("closeMenuWindow_Clone")
    else
        tes3ui.leaveMenuMode()
    end
end

return commonUtil
