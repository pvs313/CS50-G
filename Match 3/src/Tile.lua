--[[
	GD50
	Match-3 Remake

	-- Tile Class --

	Author: Colton Ogden
	cogden@cs50.harvard.edu

	The individual tiles that make up our game board. Each Tile can have a
	color and a variety, with the varietes adding extra points to the matches.
]]

Tile = Class{}

function Tile:init(x, y, color, variety, shiny)

	-- board positions
	self.gridX = x
	self.gridY = y

	-- coordinate positions
	self.x = (self.gridX - 1) * 32
	self.y = (self.gridY - 1) * 32

	-- tile appearance/points
	self.color = color
	self.variety = variety
	self.shiny = shiny

	self.pSystem = love.graphics.newParticleSystem(gTextures['shiny'], 10)
	if self.shiny then
		self.pSystem:setParticleLifetime(0.8, 1)
		self.pSystem:setEmissionRate(4)
		self.pSystem:setAreaSpread('uniform', 12, 12, 0, false)
		self.pSystem:setEmitterLifetime(-1)
		self.pSystem:start()
		self.pSystem:setSizeVariation(1)
		self.pSystem:setColors(255, 255, 255, 255, 255, 255, 255, 0)
		self.pSystem:setPosition(self.x + GRID_START_X + 16, self.y + GRID_START_Y + 16)
	end

end

function Tile:update(dt)
	if self.shiny then
		self.pSystem:update(dt)
		self.pSystem:setPosition(self.x + GRID_START_X + 16, self.y + GRID_START_Y + 16)
	end
end

function Tile:render(x, y)

	love.graphics.setColor(34, 32, 52, 255)
	love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
		self.x + x + 2, self.y + y + 2)

	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
		self.x + x, self.y + y)

	if self.shiny then
		love.graphics.draw(self.pSystem)
	end
end
