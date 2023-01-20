require "/scripts/vec2.lua"

function init()
  self.specialLast = false
  self.active = false
  self.fireTimer = 0
  animator.rotateGroup("guns", 0, true)
  self.level = config.getParameter("mechLevel", 6)
  self.groundFrames = 1
  self.worldBottomDeathLevel = 5
  
  self.maxHealth = config.getParameter("maxHealth",1750)
  self.protection = config.getParameter("protection",65)
  self.materialKind = config.getParameter("materialKind","robotic")
  
  --this comes in from the controller.
  self.ownerKey = config.getParameter("ownerKey")
  vehicle.setPersistent(self.ownerKey)

  --assume maxhealth
  if (storage.health) then
    animator.setAnimationState("movement", "idle")     
  else
    local startHealthFactor = config.getParameter("startHealthFactor")

    if (startHealthFactor == nil) then
        storage.health = self.maxHealth or 1
    else
       storage.health = math.min(startHealthFactor * self.maxHealth, self.maxHealth)
    end    
    animator.setAnimationState("movement", "idle")  -- change to warping
  end

  --setup the store functionality  
  message.setHandler("store",
      function(_, _, ownerKey)
        if (self.ownerKey and self.ownerKey == ownerKey and self.driver == nil and animator.animationState("movement") == "idle") then
--          animator.setAnimationState("movement", "warp")
          vehicle.destroy()
          return {storable = true, healthFactor = storage.health / self.maxHealth}
        else
          return {storable = false, healthFactor = storage.health / self.maxHealth}
        end
      end)

end

function update()
  if mcontroller.position()[2] < self.worldBottomDeathLevel then
    vehicle.destroy()
    return
  end

  local mechAimLimit = config.getParameter("mechAimLimit") * math.pi / 180
  local mechHorizontalMovement = config.getParameter("mechHorizontalMovement")
  local mechJumpVelocity = config.getParameter("mechJumpVelocity")
  local mechFireCycle = config.getParameter("mechFireCycle")
  local mechProjectile = config.getParameter("mechProjectile")
  local mechProjectileConfig = config.getParameter("mechProjectileConfig")
  local offGroundFrames = config.getParameter("offGroundFrames")

  local mechCollisionPoly = mcontroller.collisionPoly()
  local position = mcontroller.position()

  if mechProjectileConfig.power then
    mechProjectileConfig.power = root.evalFunction("weaponDamageLevelMultiplier", self.level) * mechProjectileConfig.power
  end

  local entityInSeat = vehicle.entityLoungingIn("seat")
  if entityInSeat then
    vehicle.setDamageTeam(world.entityDamageTeam(entityInSeat))
  else
    vehicle.setDamageTeam({type = "passive"})
  end
  updateMechDamageEffects(false)--lpk

  local diff = world.distance(vehicle.aimPosition("seat"), mcontroller.position())
  local aimAngle = math.atan(diff[2], diff[1])
  local facingDirection = (aimAngle > math.pi / 2 or aimAngle < -math.pi / 2) and -1 or 1

  if facingDirection < 0 then
    animator.setFlipped(true)

    if aimAngle > 0 then
      aimAngle = math.max(aimAngle, math.pi - mechAimLimit)
    else
      aimAngle = math.min(aimAngle, -math.pi + mechAimLimit)
    end

    animator.rotateGroup("guns", math.pi - aimAngle)
  else
    animator.setFlipped(false)

    if aimAngle > 0 then
      aimAngle = math.min(aimAngle, mechAimLimit)
    else
      aimAngle = math.max(aimAngle, -mechAimLimit)
    end

    animator.rotateGroup("guns", aimAngle)
  end

  local onGround = mcontroller.onGround()
  local movingDirection = 0

  if vehicle.controlHeld("seat", "left") and onGround then
    mcontroller.setXVelocity(-mechHorizontalMovement)
    movingDirection = -1
  end

  if vehicle.controlHeld("seat", "right") and onGround then
    mcontroller.setXVelocity(mechHorizontalMovement)
    movingDirection = 1
  end

  if onGround then
    self.groundFrames = offGroundFrames
  else
    self.groundFrames = self.groundFrames - 1
  end

  if vehicle.controlHeld("seat", "jump") and onGround then
    mcontroller.setXVelocity(mechJumpVelocity[1] * movingDirection)
    mcontroller.setYVelocity(mechJumpVelocity[2])
    animator.setAnimationState("movement", "jump")
    self.groundFrames = 0
  end

  if self.groundFrames <= 0 then
    if mcontroller.velocity()[2] > 0 then
      animator.setAnimationState("movement", "jump")
    else
      animator.setAnimationState("movement", "fall")
    end
  elseif movingDirection ~= 0 then
    if facingDirection ~= movingDirection then
      animator.setAnimationState("movement", "backWalk")
    else
      animator.setAnimationState("movement", "walk")
    end
  elseif onGround then
    animator.setAnimationState("movement", "idle")
  end

  if vehicle.controlHeld("seat", "primaryFire") then
    if self.fireTimer <= 0 then
      world.spawnProjectile(mechProjectile, vec2.add(mcontroller.position(), animator.partPoint("frontGun", "firePoint")), entity.id(), {math.cos(aimAngle), math.sin(aimAngle)}, false, mechProjectileConfig)
      self.fireTimer = self.fireTimer + mechFireCycle
      animator.setAnimationState("frontFiring", "fire")
    else
      local oldFireTimer = self.fireTimer
      self.fireTimer = self.fireTimer - script.updateDt()
      if oldFireTimer > mechFireCycle / 2 and self.fireTimer <= mechFireCycle / 2 then
        world.spawnProjectile(mechProjectile, vec2.add(mcontroller.position(), animator.partPoint("backGun", "firePoint")), entity.id(), {math.cos(aimAngle), math.sin(aimAngle)}, false, mechProjectileConfig)
        animator.setAnimationState("backFiring", "fire")
      end
    end
  end
end

--- applyDamage copypasta
function applyDamage(damageRequest)
  local damage = 0
  if damageRequest.damageType == "Damage" or damageRequest.damageType == "IgnoresDef" then
    damage = damage + root.evalFunction2("protection", damageRequest.damage, self.protection)
  elseif damageRequest.damageType == "IgnoresDef" then
    damage = damage + damageRequest.damage
  else
    return {}
  end

  if damage > 0 then
    updateMechDamage(damage)
    storage.health = storage.health - damage
  end

  if vehicle.getParameter then
  return {{
    sourceEntityId = damageRequest.sourceEntityId,
    targetEntityId = entity.id(),
    position = mcontroller.position(),
    damageDealt = damage,
    hitType = "Hit",
    damageSourceKind = damageRequest.damageSourceKind,
    targetMaterialKind = self.materialKind,
    killed = storage.health <= 0
  }}
  else
  return {{
    sourceEntityId = damageRequest.sourceEntityId,
    targetEntityId = entity.id(),
    position = mcontroller.position(),
    damageDealt = damage,
    healthLost = damage,
    hitType = "Hit",
    damageSourceKind = damageRequest.damageSourceKind,
    targetMaterialKind = self.materialKind,
    killed = storage.health <= 0
  }}
  end

end

function updateMechDamage(damage)
local oldhp = storage.health / self.maxHealth
local newhp = (storage.health - damage) / self.maxHealth

  if oldhp > 0.8 and newhp <= 0.8 or oldhp > 0.6 and newhp <= 0.6
  or oldhp > 0.4 and newhp <= 0.4 or oldhp > 0.2 and newhp <= 0.2 then 
    updateMechDamageEffects(true) -- damageShards every 20%
  end

  if newhp <= 0 then -- blow chunks and EXPLOSIONS!
    local projectileConfig = {
      damageTeam = { type = "indiscriminate" },
      power = 1,
      onlyHitTerrain = true,
      timeToLive = 0,
      actionOnReap = {
        {
          action = "config",
          file =  "/projectiles/explosions/regularexplosion2/regularexplosion2.config"
        }
      }
    }

    updateMechDamageEffects(true)
    animator.burstParticleEmitter("wreckage")

    vehicle.destroy()  -- your head asplode!
    world.spawnProjectile("invisibleprojectile", mcontroller.position(), 0, {0, 0}, false, projectileConfig)
  end

end

function updateMechDamageEffects(dropShards)
if dropShards then animator.burstParticleEmitter("damageShards") return end
local curhealth = storage.health/self.maxHealth
  if curhealth > 0.5 or math.random() < curhealth then return end  -- undamaged, gtfo
  
  bbox = mcontroller.localBoundBox()
  ubox = {bbox[1]+(bbox[3]-bbox[1])*0.2,0,bbox[3]-(bbox[3]-bbox[1])*0.2,bbox[4]}
  lbox = {bbox[1]+(bbox[3]-bbox[1])*0.25,-1.5,bbox[3]-(bbox[3]-bbox[1])*0.25,bbox[4]}
  animator.setParticleEmitterOffsetRegion("smoke1",ubox)
  animator.setParticleEmitterOffsetRegion("smoke2",ubox)
  animator.setParticleEmitterOffsetRegion("fire1",lbox)
  animator.setParticleEmitterOffsetRegion("fire2",lbox)
  
  if curhealth <= 0.5 and math.random()/2 > curhealth then    -- 1 smoke
    animator.burstParticleEmitter("smoke1")    
  end
  if curhealth <= 0.4 and math.random()/2 > curhealth then    -- 1 smoke
    animator.burstParticleEmitter("smoke1")    
  end
  if curhealth <= 0.3 and math.random()/2 > curhealth then
    animator.burstParticleEmitter("smoke1")    
  end
  if curhealth <= 0.2 and math.random()/2 > curhealth then
   -- 1 smoke 1 fire
    animator.burstParticleEmitter("smoke2")    
    animator.burstParticleEmitter("fire1")
  end
  if curhealth <= 0.1 and math.random()/2 > curhealth then
    -- 2 fire
    animator.burstParticleEmitter("fire1")
    animator.burstParticleEmitter("fire2")
  end


end
