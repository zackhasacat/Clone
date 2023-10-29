--[[
    Mod: TES3UI TextInput
    Author: Hrnchamd
]]
--

local this = {}


local pathPrefix = "VerticalityGangProject.scripts.CloningAvatar"
local rightBlock
local button_block
local cloneData  = require(pathPrefix .. ".common.cloneData")
local playerCloneData
local selectedId

local buttonId
function this.init()
    this.id_menu = tes3ui.registerID("zhac_clone:MenuTextInput")
    this.id_input = tes3ui.registerID("zhac_clone:MenuTextInput_Text")
    this.id_ok = tes3ui.registerID("zhac_clone:MenuTextInput_Ok")
    this.id_cancel = tes3ui.registerID("zhac_clone:MenuTextInput_Cancel")
    this.id_createClone = tes3ui.registerID("zhac_clone:MenuTextid_createClone")
end

local clonePaneData
-- Create window and layout. Called by onCommand.
function this.createWindow(bid)
    if (tes3ui.findMenu(this.id_menu) ~= nil) then
        return
    end
    buttonId = bid
    -- Create window and frame
    local menu = tes3ui.createMenu { id = this.id_menu, fixedFrame = true }
    menu.alpha = 1.0
    menu.width = 400

    -- Create label for the select menu
    local inputLabel = menu:createLabel { text = "Clone Pod Management" }
    local infoLabel = menu:createLabel { text = "Current Occupant: None" }
    local spacerLabel = menu:createLabel { text = "" }
    inputLabel.borderBottom = 5

    -- Create layout
    local mainBlock = menu:createBlock()
    mainBlock.flowDirection = "left_to_right"
    mainBlock.autoHeight = true
    mainBlock.autoWidth = true

    -- local leftBlock = mainBlock:createBlock()
    -- leftBlock.flowDirection = "top_to_bottom"
    ----leftBlock.autoHeight = true
    --leftBlock.autoWidth = true

    rightBlock = mainBlock:createBlock()
    rightBlock.flowDirection = "top_to_bottom"
    rightBlock.autoHeight = true
    rightBlock.autoWidth = true

    -- Create select menu
    -- local scrollPane = leftBlock:createVerticalScrollPane({ id = "myPane" })


    -- Create labels on the right
    local label1
    local label2
    local label3

    label3 = rightBlock:createLabel { text = "Available Corupus Meat: 1" }
    label2 = rightBlock:createLabel { text = "Available Daedra Heart: 1" }
    label1 = rightBlock:createLabel { text = "Available Frost Salt: 1" }
    --scrollPane.width = 300
    -- scrollPane.autoHeight = true
    -- scrollPane.childAlignX = 0.5
    -- scrollPane.childAlignY = 0.5
    -- scrollPane.positionY = 8
    --scrollPane.minWidth = 250
    -- scrollPane.minHeight = 300
    -- scrollPane.autoWidth = true
    -- scrollPane.autoHeight = true

    button_block = menu:createBlock {}
    button_block.widthProportional = 1.0 -- width is 100% parent width
    button_block.autoHeight = true
    button_block.childAlignX = -1.0      -- right content alignment

    local button_cancel = button_block:createButton { id = this.id_cancel, text = tes3.findGMST("sCancel").value }
    --  local button_ok = button_block:createButton { id = this.id_ok, text = "Control Selected" }
    local button_createClone = button_block:createButton { id = this.id_createClone, text = "Create Clone" }


    button_cancel:register(tes3.uiEvent.mouseClick, this.onCancel)
    menu:register(tes3.uiEvent.keyEnter, this.onCloneCreate) -- only works when text input is not captured
    button_createClone:register(tes3.uiEvent.mouseClick, this.onCloneCreate)
    -- Register key events
    menu:register("keyEnter", this.onCloneCreate)
    menu:register("keyEsc", this.onCancel)

    menu:updateLayout()
    tes3ui.enterMenuMode(this.id_menu)
end

function this.onCloneCreate()
    local menu = tes3ui.findMenu(this.id_menu)
    if cloneData.getCloneIDForPod(buttonId) then
        tes3ui.showNotifyMenu("Clone already occupied")
        return
    end
    --make sure the clone tube is empty, and we have the items needed
    if buttonId == "tdm_controlpanel_left" then
        local newClone = cloneData.addCloneToWorld("gnisis, arvs-drelen", { x = 4637, y = 6015, z = 146 })
        cloneData.setClonePodName(newClone.createdCloneId, buttonId)
    end
    if (menu) then
        -- Copy text *before* the menu is destroyed

        tes3ui.leaveMenuMode()
        menu:destroy()
    end
end

-- OK button callback.
function this.onOK(e)
    if not selectedId then
        return
    end
    local destActor = cloneData.getCloneObject(selectedId)
    if tes3.player.id == destActor.id then
        error("Player and dest are the same")
    end
    cloneData.transferPlayerData(tes3.player, destActor, true)
    local menu = tes3ui.findMenu(this.id_menu)

    if (menu) then
        -- Copy text *before* the menu is destroyed

        tes3ui.leaveMenuMode()
        menu:destroy()
    end
end

-- Cancel button callback.
function this.onCancel(e)
    local menu = tes3ui.findMenu(this.id_menu)

    if (menu) then
        tes3ui.leaveMenuMode()
        menu:destroy()
    end
end

-- Keydown callback.
function this.onCommand(e)
    local t = tes3.getPlayerTarget()
    if (t) then
        t = t.object.baseObject or t.object -- Select actor base object

        if (t.name) then
            this.item = t
            this.createWindow()
        end
    end
end

event.register(tes3.event.initialized, this.init)
--   event.register(tes3.event.keyDown, this.onCommand, { filter = tes3.scanCode["/"] }) -- "/" key
return this
