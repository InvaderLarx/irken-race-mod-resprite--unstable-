function init()
  protection = config.getParameter("protection", 1)

  effect.addStatModifierGroup({
    {stat = "biomeradiationImmunity", amount = protection},
   
  })

   script.setUpdateDelta(0)
end

function input(args)
end

function uninit()
end
