function init()
  protection = config.getParameter("protection", 1)

  effect.addStatModifierGroup({
    {stat = "poisonStatusImmunity", amount = protection},
    {stat = "breathProtection", amount = protection},
    {stat = "wetImmunity", amount = protection},
  })

   script.setUpdateDelta(0)
end

function input(args)
end

function uninit()
end
