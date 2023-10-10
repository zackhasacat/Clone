local self = require("openmw.self")
local core = require("openmw.core")
local lastCell
local function onUpdate(dt)
    if self.cell ~= lastCell then
        lastCell = self.cell
        core.sendGlobalEvent("updateClonedataLocation", self)
    end
end

return {
    engineHandlers = {
        onUpdate = onUpdate
    }
}
