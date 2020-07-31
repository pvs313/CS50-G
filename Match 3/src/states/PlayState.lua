--[[
	GD50
	Match-3 Remake

	-- PlayState Class --

	Author: Colton Ogden
	cogden@cs50.harvard.edu

	State in which we can actually play, moving around a grid cursor that
	can swap two tiles; when two tiles make a legal swap (a swap that results
	in a valid match), perform the swap and destroy all matched tiles, adding
	their values to the player's point score. The player can continue playing
	until they exceed the number of points needed to get to the next level
	or until the time runs out, at which point they are brought back to the
	main menu or the score entry menu if they made the top 10.
]]

PlayState = Class{__includes = BaseState}

function PlayState:init()

	-- position in the grid which we're highlighting
	self.boardCursorX = 0
	self.boardCursorY = 0

	-- timer used to switch the highlight rect's color
	self.rectHighlighted = false

	self.canInput = true

	-- tile we're currently highlighting (preparing to swap)
	self.highlightedTile = nil

	self.matches = {}

	self.cursorX = 0
	self.cursorY = 0

	self.score = 0
	self.timer = 60

	self.cursorBoundLow = 0
	self.cursorBoundHigh = 256



	Timer.every(0.5, function()
		self.rectHighlighted = not self.rectHighlighted
	end)


	Timer.every(1, function()
		self.timer = self.timer - 1

		if self.timer <= 5 then
			gSounds['clock']:play()
		end
	end)
end

function PlayState:enter(params)

	-- grab level # from the params we're passed
	self.level = params.level

	-- spawn a board and place it toward the right
	self.board = params.board or Board(GRID_START_X, GRID_START_Y, self.level)

	-- grab score from params if it was passed
	self.score = params.score or 0

	-- score we have to reach to get to the next level
	self.scoreGoal = self.level * 1.25 * 1000

	-- start our transition alpha at full, so we fade in
	self.transitionAlpha = params.alpha
end

function PlayState:update(dt)
	if love.keyboard.wasPressed('escape') then
		love.event.quit()
	end

	self.board:update(dt)
	if self.board:checkIfStuck() then
		gStateMachine:change('reset', {
			score = self.score,
			timer = self.timer,
			level = self.level,
			goal = self.scoreGoal
		})
	end

	self.cursorX, self.cursorY = love.mouseCoordinates()
	if self.cursorX == nil then
		self.cursorX = VIRTUAL_WIDTH + 272
	end
	if self.cursorY == nil then
		self.cursorY = GRID_START_Y
	end
	self.cursorX = self.cursorX - VIRTUAL_WIDTH + 272
	self.cursorY = self.cursorY - GRID_START_Y

	if self.timer <= 0 then
		Timer.clear()

		gSounds['game-over']:play()

		gStateMachine:change('game-over', {
			score = self.score
		})
	end

	-- go to next level if we surpass score goal
	if self.score >= self.scoreGoal then
		Timer.clear()

		gSounds['next-level']:play()

		-- change to begin game state with new level (incremented)
		gStateMachine:change('begin-game', {
			level = self.level + 1,
			score = self.score
		})
	end

	if self.canInput and self:mouseInBounds() then
		self.boardCursorX = math.floor(self.cursorX / 32)
		self.boardCursorY = math.floor(self.cursorY / 32)

		if love.mouse.wasPressed(1) then
			local x = math.min(math.max(0, self.boardCursorX) + 1, 8)
			local y = math.min(math.max(0, self.boardCursorY) + 1, 8)
			if not self.highlightedTile then
				self.highlightedTile = self.board.tiles[y][x]
				gSounds['select']:stop()
				gSounds['select']:play()
			elseif self.highlightedTile == self.board.tiles[y][x] then
				self.highlightedTile = nil
			elseif math.abs(self.highlightedTile.gridX - x) + math.abs(self.highlightedTile.gridY - y) > 1 then
				gSounds['error']:stop()
				gSounds['error']:play()
				self.highlightedTile = nil
			else
				local tempX = self.highlightedTile.gridX
				local tempY = self.highlightedTile.gridY

				local newTile = self.board.tiles[y][x]

				self.highlightedTile.gridX = newTile.gridX
				self.highlightedTile.gridY = newTile.gridY
				newTile.gridX = tempX
				newTile.gridY = tempY

				self.board.tiles[self.highlightedTile.gridY][self.highlightedTile.gridX] =
					self.highlightedTile

				self.board.tiles[newTile.gridY][newTile.gridX] = newTile

				local match = self.board:calculateMatches()

				-- tween coordinates between the two so they swap
				Timer.tween(0.1, {
					[self.highlightedTile] = {x = newTile.x, y = newTile.y},
					[newTile] = {x = self.highlightedTile.x, y = self.highlightedTile.y}
				}):finish(function()
					if match == false then

						Timer.tween(0.1, {
							[self.highlightedTile] = {x = newTile.x, y = newTile.y},
							[newTile] = {x = self.highlightedTile.x, y = self.highlightedTile.y}
						})
						tempX = self.highlightedTile.gridX
						tempY = self.highlightedTile.gridY

						self.highlightedTile.gridX = newTile.gridX
						self.highlightedTile.gridY = newTile.gridY

						newTile.gridX = tempX
						newTile.gridY = tempY

						self.board.tiles[self.highlightedTile.gridY][self.highlightedTile.gridX] =
							self.highlightedTile
						self.board.tiles[newTile.gridY][newTile.gridX] = newTile

						gSounds['error']:stop()
						gSounds['error']:play()

						self.highlightedTile = nil
					else
						self.matches = match
						self:calculateMatches()
					end
				end)
			end
		end
	end

	Timer.update(dt)
end

--[[
	Calculates whether any matches were found on the board and tweens the needed
	tiles to their new destinations if so. Also removes tiles from the board that
	have matched and replaces them with new randomized tiles, deferring most of this
	to the Board class.
]]
function PlayState:calculateMatches()
	self.highlightedTile = nil


	if self.matches == nil then
		self.matches = self.board:calculateMatches()
	end

	if self.matches then
		gSounds['match']:stop()
		gSounds['match']:play()

		-- add score for each match
		for k, match in pairs(self.matches) do
			self.score = self.score + #match * 50
			for i, tile in pairs(match) do
				self.score = self.score + tile.variety * 10 - 10
			end
			self.timer = self.timer + 1
		end

		-- remove any tiles that matched from the board, making empty spaces
		self.board:removeMatches()
		self.matches = nil
		local tilesToFall = nil
		local tileCount = 0
		tilesToFall, tileCount = self.board:getFallingTiles()
		tileCount = math.max(tileCount, 5)

		-- tween new tiles that spawn from the ceiling over time to fill in
		-- the new upper gaps that exist

		Timer.tween(0.05 * tileCount, tilesToFall):finish(function()
			self:calculateMatches()
		end)


	else
		self.canInput = true
	end
end

function PlayState:mouseInBounds()
	if (self.cursorX >= self.cursorBoundLow) and
	   (self.cursorY >= self.cursorBoundLow) and
	   (self.cursorX <= self.cursorBoundHigh) and
	   (self.cursorY <= self.cursorBoundHigh) then
		return true
	else
		return false
	end
end

function PlayState:render()
	-- render board of tiles
	self.board:render()

	-- render highlighted tile if it exists
	if self.highlightedTile then

		-- multiply so drawing white rect makes it brighter
		love.graphics.setBlendMode('add')

		love.graphics.setColor(255, 255, 255, 96)
		love.graphics.rectangle('fill', (self.highlightedTile.gridX - 1) * 32 + (GRID_START_X),
			(self.highlightedTile.gridY - 1) * 32 + GRID_START_Y, 32, 32, 4)

		-- back to alpha
		love.graphics.setBlendMode('alpha')
	end

	-- render highlight rect color based on timer
	if self.rectHighlighted then
		love.graphics.setColor(217, 87, 99, 255)
	else
		love.graphics.setColor(172, 50, 50, 255)
	end

	if self:mouseInBounds() then
		love.graphics.setLineWidth(4)
		love.graphics.rectangle('line', self.boardCursorX * 32 + (GRID_START_X),
			self.boardCursorY * 32 + GRID_START_Y, 32, 32, 4)
	end

	love.graphics.setColor(255, 255, 255, 255)

	love.graphics.setColor(56, 56, 56, 234)
	love.graphics.rectangle('fill', 16, 16, 186, 116, 4)

	love.graphics.setColor(99, 155, 255, 255)
	love.graphics.setFont(gFonts['medium'])
	love.graphics.printf('Level: ' .. tostring(self.level), 20, 24, 182, 'center')
	love.graphics.printf('Score: ' .. tostring(self.score), 20, 52, 182, 'center')
	love.graphics.printf('Goal : ' .. tostring(self.scoreGoal), 20, 80, 182, 'center')
	love.graphics.printf('Timer: ' .. tostring(self.timer), 20, 108, 182, 'center')
end
