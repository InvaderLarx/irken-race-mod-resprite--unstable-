function init()
  protection = config.getParameter("protection", 1)

  effect.addStatModifierGroup({
    {stat = "breathProtection", amount = protection},
    {stat = "biomeradiationImmunity", amount = protection},
	{stat = "biomecoldImmunity", amount = protection},
	{stat = "biomeheatImmunity", amount = protection}
  })

   script.setUpdateDelta(0)
end

function input(args)
end

function uninit()
end
