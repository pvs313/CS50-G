--[[
	GD50
	Legend of Zelda

	Author: Colton Ogden
	cogden@cs50.harvard.edu
]]

Entity = Class{}

function Entity:init(def)

	-- in top-down games, there are four directions instead of two
	self.direction = 'down'

	self.animations = self:createAnimations(def.animations)

	-- dimensions
	self.x = def.x
	self.y = def.y
	self.width = def.width
	self.height = def.height

	self.room = def.room

	-- drawing offsets for padded sprites
	self.offsetX = def.offsetX or 0
	self.offsetY = def.offsetY or 0

	self.walkSpeed = def.walkSpeed

	self.health = def.health

	if def.flier ~= nil then
		self.flier = def.flier
	else
		self.flier = false
	end

	self.hitbox = Hitbox {
		padX = def.hitbox.padX,
		padY = def.hitbox.padY,
		width = def.hitbox.width,
		height = def.hitbox.height
	}
	self.hurtbox = Hitbox {
		padX = def.hurtbox.padX,
		padY = def.hurtbox.padY,
		width = def.hurtbox.width,
		height = def.hurtbox.height,
	}
	-- Setting the absolute coordinates
	self.hitbox:move(self.x, self.y)
	self.hurtbox:move(self.x, self.y)

	self.invulnerable = false
	self.invulnerableDuration = 0
	self.invulnerableTimer = 0
	self.flashTimer = 0
	self.directionHit = 'none'
	self.dead = false
	self.psystem = love.graphics.newParticleSystem(gTextures['particle'], 32)
	self.psystem:setParticleLifetime(0.5, 1)
	self.psystem:setEmitterLifetime(0.5)
	self.psystem:setEmissionRate(32)
	self.psystem:setAreaSpread('uniform', 1, 1)
	self.psystem:setColors(0, 0, 255, 255, 255, 0, 255, 255)
	self.damageFlash = false
	self.onDeath = def.onDeath
	self.bumped = false
	self.liftOffsetX = def.liftOffsetX
	self.liftOffsetY = def.liftOffsetY
	self.inLiftRange = false
	self.item = nil
	self.liftHitboxDisplayTimer = 0
end

function Entity:createAnimations(animations)
	local animationsReturned = {}

	for k, animationDef in pairs(animations) do
		animationsReturned[k] = Animation {
			texture = animationDef.texture or 'entities',
			frames = animationDef.frames,
			interval = animationDef.interval
		}
	end

	return animationsReturned
end

function Entity:collides(target)
	return not (self.hurtbox.x + self.hurtbox.width < target.x or self.hurtbox.x > target.x + target.width or
				self.hurtbox.y + self.hurtbox.height < target.y or self.hurtbox.y > target.y + target.height)
end
function Entity:unCollide(target, dt)
	local boxEndX = self.hurtbox.x + self.width
	local boxEndY = self.hurtbox.y + self.height
	local tEndX = target.x + target.width
	local tEndY = target.y + target.height

	if boxEndX >= target.x and self.hurtbox.x <= tEndX then
		if math.abs(boxEndX - target.x) < math.abs(self.hurtbox.x - tEndX) - 4 then
			self.x = self.x - (self.walkSpeed * dt)
		elseif math.abs(boxEndX - target.x) > math.abs(self.hurtbox.x - tEndX) + 8 then
			self.x = self.x + (self.walkSpeed * dt)
		end
	end
	if boxEndY >= target.y and self.hurtbox.y <= tEndY then
		if math.abs(boxEndY - target.y) < math.abs(self.hurtbox.y - tEndY) + 4 then
			self.y = self.y - (self.walkSpeed * dt)
		elseif math.abs(boxEndY - target.y) > math.abs(self.hurtbox.y - tEndY) + 15 then
			self.y = self.y + (self.walkSpeed * dt)
		end
	end
end

function Entity:damage(dmg)
	if self.health > 0 then
		self.health = self.health - dmg
		self.damageFlash = true
		Timer.after(1, function()
			self.damageFlash = false
		end)
		if self.directionHit == 'down' or (self.directionHit == 'none' and self.direction == 'down')  then
			Timer.tween(KNOCKBACK_SPEED, {
				[self] = {y = math.max(MAP_TOP_EDGE - self.height / 2, self.y - (2 * TILE_SIZE))}
			}):finish(function()
				if self.health <= 0 then
					self:death()
				end
			end)
		elseif self.directionHit == 'up' or (self.directionHit == 'none' and self.direction == 'up') then
			Timer.tween(KNOCKBACK_SPEED, {
				[self] = {y =  math.min(MAP_BOTTOM_EDGE - self.height, self.y + (2 * TILE_SIZE))}
			}):finish(function()
				if self.health <= 0 then
					self:death()
				end
			end)
		elseif self.directionHit == 'left' or (self.directionHit == 'none' and self.direction == 'left') then
			Timer.tween(KNOCKBACK_SPEED, {
				[self] = {x =  math.min(MAP_RIGHT_EDGE - self.width, self.x + (2 * TILE_SIZE))}
			}):finish(function()
				if self.health <= 0 then
					self:death()
				end
			end)
		elseif self.directionHit == 'right' or (self.directionHit == 'none' and self.direction == 'right') then
			Timer.tween(KNOCKBACK_SPEED, {
				[self] = {x =  math.max(MAP_LEFT_EDGE - self.height / 2, self.x - (2 * TILE_SIZE))}
			}):finish(function()
				if self.health <= 0 then
					self:death()
				end
			end)
		end
	end
end

function Entity:death()
	if self.directionHit == 'right' then
		self.psystem:setLinearAcceleration(-50, -20, -20, 20)
	elseif self.directionHit == 'left' then
		self.psystem:setLinearAcceleration(20, -20, 50, 20)
	elseif self.directionHit == 'up' then
		self.psystem:setLinearAcceleration(-20, 20, 20, 50)
	elseif self.directionHit == 'down' then
		self.psystem:setLinearAcceleration(-20, -50, 20, -20)
	else
		self.psystem:setLinearAcceleration(-20, -20, 20, 20)
	end

	self.psystem:emit(32)
	if self.onDeath ~= nil then
		self.onDeath(self)
	end

	self.dead = true
end

function Entity:goInvulnerable(duration)
	self.invulnerable = true
	self.invulnerableDuration = duration
end

function Entity:changeState(name)
	self.stateMachine:change(name)
end

function Entity:changeAnimation(name)
	self.currentAnimation = self.animations[name]
end

function Entity:update(dt)
	if not self.dead then
		if self.invulnerable then
			self.flashTimer = self.flashTimer + dt
			self.invulnerableTimer = self.invulnerableTimer + dt

			if self.invulnerableTimer > self.invulnerableDuration then
				self.invulnerable = false
				self.invulnerableTimer = 0
				self.invulnerableDuration = 0
				self.flashTimer = 0
			end
		end

		self.stateMachine:update(dt)

		self.hurtbox:move(self.x, self.y)
		self.hitbox:move(self.x, self.y)

		if self.currentAnimation then
			self.currentAnimation:update(dt)
		end
	else
		self.psystem:update(dt)
	end

	self.liftHitboxDisplayTimer = self.liftHitboxDisplayTimer - dt
end

function Entity:checkObjectCollisions(dt)
	if not self.flier then
		for k, object in pairs(self.room.objects) do
			if object.solid then
				if self:collides(object) then
					self.bumped = true
					self:unCollide(object, dt)
				end
			end
		end
	end
end


function Entity:attemptLift(dt)
	local padX, padY, hitboxWidth, hitboxHeight
	if self.direction == 'left' then
		hitboxWidth = 5
		hitboxHeight = 5
		padX = -hitboxWidth + self.hurtbox.padX
		padY = self.hurtbox.padY + self.hurtbox.height - 5
	elseif self.direction == 'right' then
		hitboxWidth = 5
		hitboxHeight = 5
		padX = self.hurtbox.width + self.hurtbox.padX
		padY = self.hurtbox.padY + self.hurtbox.height - 5
	elseif self.direction == 'up' then
		hitboxWidth = 5
		hitboxHeight = 5
		padX = self.hurtbox.padX + self.hurtbox.width / 4 + 1
		padY = self.hurtbox.padY - 5
	else
		hitboxWidth = 5
		hitboxHeight = 5
		padX = self.hurtbox.padX + self.hurtbox.width / 4 + 1
		padY = self.hurtbox.padY + self.hurtbox.height
	end

	self.liftHitbox = Hitbox {
		padX = padX,
		padY = padY,
		height = hitboxHeight,
		width = hitboxWidth
	}
	self.liftHitbox:move(self.x, self.y)

	for k, object in pairs(self.room.objects) do
		if self.liftHitbox:collides(object) and object.liftable then
			self.item = object
			table.remove(self.room.objects, k)
			break
		end
		if self.item then
			break
		end
	end

	self.liftHitboxDisplayTimer = 1
end

function Entity:processAI(dt)
	self.stateMachine:processAI(dt)
end

function Entity:render(adjacentOffsetX, adjacentOffsetY)
	if self.dead then
		love.graphics.draw(self.psystem, self.x + self.width/2, self.y + self.height/2)
	else
		if gRenderHitboxes then
			if self.flier == true then
				self.hurtbox:render(0, 0, 255)
			else
				self.hurtbox:render(0, 255, 0)
			end
			if self.liftHitboxDisplayTimer > 0 then
				self.liftHitbox:render(255, 255, 0)
			end
		end

		if self.damageFlash and not self.invulnerable then
			 love.graphics.setColor(255, 0, 0, 255)
		elseif self.invulnerable and self.flashTimer > 0.06 then
			self.flashTimer = 0
			love.graphics.setColor(255, 255, 255, 64)
		end

		self.x, self.y = self.x + (adjacentOffsetX or 0), self.y + (adjacentOffsetY or 0)

		self.stateMachine:render()
		love.graphics.setColor(255, 255, 255, 255)
		self.x, self.y = self.x - (adjacentOffsetX or 0), self.y - (adjacentOffsetY or 0)
	end
end
