local events = require("scripts.CloningAvatar.events")
local types = require("openmw.types")
local I = require("openmw.interfaces")
I.Activation.addHandlerForType(types.Activator, events.onActivate)
local function onConsoleCommand(command)
    events.onConsoleCommand(command)
end
local function onKeyPress(keyc)
events.onKeyPress(keyc)
end
return {
    engineHandlers = {
        onPlayerAdded = events.onInit
    },
    eventHandlers = {
        onConsoleCommand = onConsoleCommand,
        onKeyPress = onKeyPress,
    }
}
