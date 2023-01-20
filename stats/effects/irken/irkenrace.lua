require("/scripts/vec2.lua")
function init()
 effect.addStatModifierGroup({{stat = "fireStatusImmunity", amount = 1}})
 effect.addStatModifierGroup({{stat = "fallDamageMultiplier", baseMultiplier = 0.25}})

script.setUpdateDelta(5)
end

function update(dt)
			
end

function uninit()

end