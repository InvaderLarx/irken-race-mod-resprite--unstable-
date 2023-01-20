require("/scripts/vec2.lua")
local fuoldInit = init
local fuoldUpdate = update
local fuoldUninit = uninit

function init()
  fuoldInit()
  self.lastYPosition = 0
  self.lastYVelocity = 0
  self.fallDistance = 0
  local bounds = mcontroller.boundBox()
end

function update(dt)
  fuoldUpdate(dt)
  
	if world.entitySpecies(entity.id()) == "irken" then
		status.addEphemeralEffect("irkenrace",math.huge)
		status.addEphemeralEffect("shutdown",math.huge)
		if status.stat == nil then return false end
		elseif status.stat ("irkenenergeryboost") then
		status.removeEphemeralEffect("shutdown",math.huge)
	end
  end
    if worldTable then
       if (worldTable[1]==1 and waitTimer <= 0) then
           tickTimer = tickTimer - dt
           if tickTimer <= 0 then
              tickTimer = 1.0
              status.applySelfDamageRequest({
              damageType = "IgnoresDef",
              damage = math.floor(status.resourceMax("health") * 0.035) + 1,
              damageSourceKind = "default",
              sourceEntityId = entity.id()
              })
           end
       end
       elseif not worldTable then
       waitTimer = 100.0
    end

	
function uninit()
  
end
