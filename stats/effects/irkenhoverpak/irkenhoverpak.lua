function init()
  local bounds = mcontroller.boundBox()
  effect.addStatModifierGroup({
    {stat = "jumpModifier", amount = 0.5}
  })
  self.activeflag = true
  self.tech = config.getParameter("tech") or "doublejump"
end

function update(dt)
	if self.activeflag then
		world.sendEntityMessage(effect.sourceEntity(),"techChangeOn",self.tech)
		self.activeflag = false
	end
	mcontroller.controlModifiers({
		airJumpModifier = 1.35
    })
end

function uninit()
  --world.sendEntityMessage(effect.sourceEntity(),"techChangeOff")
end
