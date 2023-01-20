function init()
  --Health Scale
  effect.addStatModifierGroup({{stat = "irkenenergyboost", amount = 1}})
  self.energyModifier = config.getParameter("energyModifier", 0)
  effect.addStatModifierGroup({{stat = "maxEnergy", effectiveMultiplier = self.energyModifier}})
  --Damage for none Irkens
  self.tickDamagePercentage = 0.030
  self.tickTime = 2
  self.tickTimer = self.tickTime
  script.setUpdateDelta(5)
end

function update(dt)
if not(world.entitySpecies(entity.id()) == "irken") then
    if (self.tickTimer <= 0) then
      self.tickTimer = self.tickTime
      status.applySelfDamageRequest({
	damageType = "IgnoresDef",
	damage = math.floor(status.resourceMax("health") * self.tickDamagePercentage) + 1,
	damageSourceKind = "poison",
	sourceEntityId = entity.id()
      })     
      effect.setParentDirectives("fade=806e4f="..self.tickTimer * 0.4)
    end    
  end
  self.tickTimer = self.tickTimer - dt
end

function uninit()
end
