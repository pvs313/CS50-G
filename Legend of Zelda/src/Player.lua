--[[
	GD50
	Legend of Zelda

	Author: Colton Ogden
	cogden@cs50.harvard.edu
]]

Player = Class{__includes = Entity}

function Player:init(def)
	Entity.init(self, def)
end

function Player:update(dt)
	Entity.update(self, dt)
	if love.keyboard.wasPressed(PLAYER_ACTION) then
		self.stateMachine.current:action(dt)
	end
end

function Player:collides(target)
	if target.room == nil then
		return not (self.hurtbox.x + self.hurtbox.width < target.x or self.hurtbox.x > target.x + target.width or
					self.hurtbox.y + self.hurtbox.height < target.y or self.hurtbox.y > target.y + target.height)

	else
		return not (self.x + self.width < target.x or self.x > target.x + target.width or
					self.hurtbox.y + self.hurtbox.height < target.y or self.hurtbox.y > target.y + target.height)
	end
end

function Player:render()
	if gRenderHitboxes then
		self.hurtbox:render(0, 0, 255)
	end
	Entity.render(self)
end
