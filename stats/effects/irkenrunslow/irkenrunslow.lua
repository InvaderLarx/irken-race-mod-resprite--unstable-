function init()
  local bounds = mcontroller.boundBox()
 --Power
  self.powerModifier = config.getParameter("powerModifier", 0)
  effect.addStatModifierGroup({{stat = "powerMultiplier", effectiveMultiplier = self.powerModifier}})
end

function update(dt)
  mcontroller.controlModifiers({
      speedModifier = 0.85,
	  groundMovementModifier = 0.85,
      runModifier = 0.85,
      jumpModifier = 0.85
    })
end

function uninit()
  
end
