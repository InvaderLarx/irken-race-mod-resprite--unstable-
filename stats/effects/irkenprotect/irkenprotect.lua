function init()
  self.healingRate = 1.0 / config.getParameter("healTime", 10)
  
  protection = config.getParameter("protection", 1)

  effect.addStatModifierGroup({
    {stat = "poisonResistance", amount = 0.25},
    {stat = "electricResistance", amount = 0.25},
    {stat = "wetImmunity", amount = protection}
  })

   script.setUpdateDelta(5)
end

function update(dt)
  status.modifyResourcePercentage("health", self.healingRate * dt)
end

function input(args)
end

function uninit()
end
