PlayerLiftState = Class{__includes = BaseState}

function PlayerLiftState:init(player)
	self.entity = player
	self.entity.offsetY = 5
	self.entity.offsetX = 0
end

function PlayerLiftState:enter()
	self.entity.idle = false
	self.timer = PLAYER_LIFT_SPEED * 3 - 0.01
	self.entity:changeAnimation('lift-' .. self.entity.direction)
	self.liftAnimationStarted = false
	if self.entity.direction == 'up' then
		self.entity.item.x = self.entity.x
		self.entity.item.y = self.entity.y
	elseif self.entity.direction == 'down' then
		self.entity.item.x = self.entity.x
		self.entity.item.y = self.entity.y + self.entity.height - self.entity.item.height/2
	elseif self.entity.direction == 'left' then
		self.entity.item.x = self.entity.x - self.entity.item.width + 5
		self.entity.item.y = self.entity.y + self.entity.height - self.entity.item.height
	else
		self.entity.item.x = self.entity.x + self.entity.width - 5
		self.entity.item.y = self.entity.y + self.entity.height - self.entity.item.height
	end
end

function PlayerLiftState:update(dt)
	if self.timer < 0 then
		self.entity:changeState('idle')
	elseif (not self.liftAnimationStarted) and (self.timer < PLAYER_LIFT_SPEED) then
		Timer.tween(self.timer, {
			[self.entity.item] = {x = self.entity.x, y = self.entity.y - self.entity.item.height/2}
		})
		self.liftAnimationStarted = true
	end
	self.timer = self.timer - dt
end

function PlayerLiftState:action(dt)
end

function PlayerLiftState:render()
	if self.entity.direction == 'up' then
		self.entity.item:render(0, 0)
		local anim = self.entity.currentAnimation
		love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
			math.floor(self.entity.x - self.entity.offsetX), math.floor(self.entity.y - self.entity.offsetY))
	else
		local anim = self.entity.currentAnimation
		love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
			math.floor(self.entity.x - self.entity.offsetX), math.floor(self.entity.y - self.entity.offsetY) )
		self.entity.item:render(0, 0)
	end


end
