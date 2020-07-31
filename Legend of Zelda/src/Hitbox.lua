--[[
	GD50
	Legend of Zelda

	Author: Colton Ogden
	cogden@cs50.harvard.edu
]]

Hitbox = Class{}

function Hitbox:init(params)
	self.x = params.x
	self.y = params.y
	self.padX = params.padX
	self.padY = params.padY
	self.width = params.width
	self.height = params.height
end


function Hitbox:move(x, y)
	self.x = x + self.padX
	self.y = y + self.padY
end


function Hitbox:render(red, green, blue)
	love.graphics.setColor(red, green, blue, 255)
	love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
	love.graphics.setColor(255, 255, 255, 255)

end

function Hitbox:collides(target)
	return not (self.x + self.width < target.x or self.x > target.x + target.width or
				self.y + self.height < target.y or self.y > target.y + target.height)
end
