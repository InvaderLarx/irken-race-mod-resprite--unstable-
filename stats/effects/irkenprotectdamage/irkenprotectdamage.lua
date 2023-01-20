function init()
  self.powerModifier = config.getParameter("powerModifier", 0)
  effect.addStatModifierGroup({{stat = "powerMultiplier", effectiveMultiplier = self.powerModifier}})
  
  protection = config.getParameter("protection", 1)

  effect.addStatModifierGroup({
    {stat = "poisonResistance", amount = 0.25},
    {stat = "electricResistance", amount = 0.25},
    {stat = "wetImmunity", amount = protection}
  })

   script.setUpdateDelta(5)
end

function update(dt)
 
end

function input(args)
end

function uninit()
end
