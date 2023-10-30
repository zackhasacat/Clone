local configPath = "clone" -- The name of the config json file of your mod

local defaultConfig = {
    enabled = true,
    keybindClone = {
        keyCode = tes3.scanCode.k,
        isShiftDown = false,
        isAltDown = false,
        isControlDown = false,
    }, 
}

local config = mwse.loadConfig(configPath, defaultConfig)
local function registerModConfig()
    EasyMCM = require("easyMCM.EasyMCM")
    local template = EasyMCM.createTemplate("Clone")
    local page = template:createPage()
    local cSettings = page:createCategory("Settings")
    cSettings:createKeyBinder({
        label = "Assign Keybind",
        description = "Assign a new keybind to perform awesome tasks.",
        variable = mwse.mcm.createTableVariable{ id = "keybindClone", table = config },
        allowCombinations = true,
    })
	template:saveOnClose(configPath,config)
    EasyMCM.register(template)
end
event.register("modConfigReady", registerModConfig)
