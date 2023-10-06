local omw, core = pcall(require, "openmw.core")
local _, world = pcall(require, "openmw.world")
local _, nearby = pcall(require, "openmw.nearby")
local function getPlayer()
    if omw and world then
        return world.players[1]
    elseif omw and nearby then
        return nearby.players[1]
    end
end


return {
    getPlayer = getPlayer
}
