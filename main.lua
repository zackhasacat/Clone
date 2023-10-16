local events = require("VerticalityGangProject.scripts.CloningAvatar.events")
local commonUtil = require("VerticalityGangProject.scripts.CloningAvatar.common.commonUtil")
local command = include("JosephMcKean.commands.interop")
local function keyDown(e)
    for key, value in pairs(tes3.scanCode) do
        if value == e.keyCode then
            events.onKeyPress(key)
        end
    end
end
local function activate(e)
    events.onActivate(e.target, e.activator)
end
local function death(e)
    if e.reference.id == tes3.player.id then
        events.onPlayerDeath(e.reference)
    end
end
local function onDamage(e)

    if e.reference.id == tes3.player.id then
	if e.mobile.health.current - math.abs(e.damage) <= 1 then
        commonUtil.showMessage("Killed")
        e.damage = 0
        return false
    end
end
end
event.register(tes3.event["keyDown"], keyDown)
event.register(tes3.event["activate"], activate)
event.register(tes3.event["death"], death)
event.register(tes3.event.loaded, events.onInit)
event.register(tes3.event["damage"], onDamage)
if command then
    command.registerCommands({
        {
            name = "clonetp",
            description = "TP to clone area",
            callback = function(argv)
                commonUtil.teleportActor(commonUtil.getPlayer(), "gnisis, arvs-drelen", { x = 3870, y = 3857, z = 256 })
            end,
        },
    })
end
