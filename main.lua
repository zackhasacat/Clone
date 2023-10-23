local events = require("VerticalityGangProject.scripts.CloningAvatar.events")
local commonUtil = require("VerticalityGangProject.scripts.CloningAvatar.common.commonUtil")
local command = include("JosephMcKean.commands.interop")
local SkillsModule = include("SkillsModule")
if not SkillsModule then return end

local skill = SkillsModule.registerSkill{
    id = "cloning",
    name = "Cloning",
    description = "The cloning skill determines how well you can create and use clones.",
    specialization = tes3.specialization["magic"],
    value = 0,
    maxLevel = -1,
   -- icon = "Icons/HuntingMod/hunting.dds"
}
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
local function soundObjectPlayCallback(e)
    --  return false
end
event.register(tes3.event.soundObjectPlay, soundObjectPlayCallback)
local function onDamage(e)
    if e.reference.id == tes3.player.id then
        if commonUtil.playerIsInClone() then
        if e.mobile.health.current - math.abs(e.damage) <= 1 then
            commonUtil.showMessage("Killed")
            e.damage = 0
            e.mobile.health.current = 1000
            events.onPlayerDeath()
            return false
        end
    end
    end
end
event.register(tes3.event["keyDown"], keyDown)
event.register(tes3.event["activate"], activate)
event.register(tes3.event["death"], death)
event.register(tes3.event.loaded, events.onInit)
event.register(tes3.event["damage"], onDamage, { priority = -100 })
if command then
    command.registerCommands({
        {
            name = "clonetp",
            description = "TP to clone area",
            callback = function(argv)
                events.onConsoleCommand("clonetp")
            end,
        },
    })
end
