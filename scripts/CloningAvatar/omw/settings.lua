local I = require('openmw.interfaces')
local storage = require('openmw.storage')
local async = require('openmw.async')
local core = require('openmw.core')
local settingsGroup = 'SettingsClone'
local playerSettings = storage.playerSection(settingsGroup)
I.Settings.registerPage {
    key = "SettingsClone",
    l10n = "SettingsClone",
    name = "Clone",
    description = ""
}
I.Settings.registerGroup {
    key = "SettingsClone",
    page = "SettingsClone",
    l10n = "SettingsClone",
    name = "Clone - Settings",
    description = "",
    permanentStorage = true,
    settings = {

         {
              key = "keyBind",
              renderer = "textLine",
              name = "Keybind to open clone menu",
              description = "Enter a key to press to open the Clone selection menu. Default is K. If invalid setting provided, default will be used.",
              default = "k"
         },

        }}

        local function updateKeyset(section, key)
            if key then
                core.sendGlobalEvent("Clone_SettingUpdate",
                    { key = key, value = storage.playerSection(section):get(key), section = section })
            end
        end
        playerSettings:subscribe(async:callback(updateKeyset))