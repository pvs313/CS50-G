--[[
	GD50
	Match-3 Remake

	-- Board Class --

	Author: Colton Ogden
	cogden@cs50.harvard.edu

	The Board is our arrangement of Tiles with which we must try to find matching
	sets of three horizontally or vertically.
]]

Board = Class{}

function Board:init(x, y, level)
	self.x = x
	self.y = y
	self.level = level
	self.matches = {}
	self.colorCount = 6
	self.varietyCount = 5
	self.tilesInPlay = {}


	self:initializeTiles()
end

function Board:tileCreator(x_pos, y_pos)
	local colorsPossible = {4, 9, 11, 12, 17, 18}
	local color = colorsPossible[math.floor(math.random(self.colorCount))]

	local variety = math.random(math.min(math.random(self.level) / 2, self.varietyCount))

	local shiny = (math.random(40) <= 1)
	local tile = Tile(x_pos, y_pos, color, variety, shiny)


	if self.tilesInPlay[color] ==  nil then
		self.tilesInPlay[color] = {}
		for i=1, self.varietyCount do
			self.tilesInPlay[color][i] = 0
		end
	end

	self.tilesInPlay[color][variety] = self.tilesInPlay[color][variety] + 1
	return tile
end

function Board:initializeTiles()
	self.tiles = {}

	for tileY = 1, 8 do

		-- empty table that will serve as a new row
		table.insert(self.tiles, {})

		for tileX = 1, 8 do
			-- -- create a new tile at X,Y with a random color and variety
			local tile = self:tileCreator(tileX, tileY)
			table.insert(self.tiles[tileY], tile)
		end
	end

	self:eraseBoard()
	self:getFallingTiles()
	self:tileCascade(1, 8)

	while self:calculateMatches() do

		self:initializeTiles()
	end
end

--[[
	Goes left to right, top to bottom in the board, calculating matches by counting consecutive
	tiles of the same color. Doesn't need to check the last tile in every row or column if the
	last two haven't been a match.
]]

function Board:calculateMatches()

	local matches = {}

	-- how many of the same color blocks in a row we've found
	local matchNum = 1

	-- horizontal matches first
	for y = 1, 8 do
		local colorToMatch = self.tiles[y][1].color

		matchNum = 1

		-- every horizontal tile
		for x = 2, 8 do

			-- if this is the same color as the one we're trying to match...
			if self.tiles[y][x].color == colorToMatch then
				matchNum = matchNum + 1
			else

				colorToMatch = self.tiles[y][x].color

				if matchNum >= 3 then
					local match = {}

					for x2 = x - 1, x - matchNum, -1 do
						if self.tiles[y][x2].shiny then
							for x3 = 1, 8 do
								table.insert(match, self.tiles[y][x3])
							end
							break
						else
							table.insert(match, self.tiles[y][x2])
						end
					end

					table.insert(matches, match)
				end

				matchNum = 1

				-- don't need to check last two if they won't be in a match
				if x >= 7 then
					break
				end
			end
		end

		-- account for the last row ending with a match
		if matchNum >= 3 then
			local match = {}

			-- go backwards from end of last row by matchNum
			for x = 8, 8 - matchNum + 1, -1 do
				table.insert(match, self.tiles[y][x])
			end

			table.insert(matches, match)
		end
	end

	-- vertical matches
	for x = 1, 8 do
		local colorToMatch = self.tiles[1][x].color

		matchNum = 1

		-- every vertical tile
		for y = 2, 8 do
			if self.tiles[y][x].color == colorToMatch then
				matchNum = matchNum + 1
			else
				colorToMatch = self.tiles[y][x].color

				if matchNum >= 3 then
					local match = {}

					for y2 = y - 1, y - matchNum, -1 do
						if self.tiles[y2][x].shiny then
							for y3 = 1, 8 do
								table.insert(match, self.tiles[y3][x])
							end
							break
						else
							table.insert(match, self.tiles[y2][x])
						end
					end

					table.insert(matches, match)
				end

				matchNum = 1

				-- don't need to check last two if they won't be in a match
				if y >= 7 then
					break
				end
			end
		end

		-- account for the last column ending with a match
		if matchNum >= 3 then
			local match = {}

			-- go backwards from end of last row by matchNum
			for y = 8, 8 - matchNum + 1, -1 do
				table.insert(match, self.tiles[y][x])
			end

			table.insert(matches, match)
		end
	end

	-- store matches for later reference
	self.matches = matches

	-- return matches table if > 0, else just return false
	return #self.matches > 0 and self.matches or false
end

--[[
	Remove the matches from the Board by just setting the Tile slots within
	them to nil, then setting self.matches to nil.
]]

function Board:removeMatches()
	for k, match in pairs(self.matches) do
		for k, tile in pairs(match) do
			self.tilesInPlay[tile.color][tile.variety] = self.tilesInPlay[tile.color][tile.variety] - 1
			self.tiles[tile.gridY][tile.gridX] = nil
		end
	end
	self.matches = nil
end

function Board:tileCascade(x, y)
	self:tileFall(x, y)
	Timer.after(0.025, function()
		if x < 8 then
			x = x + 1
		elseif x == 8 and y >= 1 then
			y = y - 1
			x = 1
		end
		if y > 0 then
			self:tileCascade(x, y)
		end
	end)
end

function Board:tileFall(gridX, gridY)
	local destination = self.tiles[gridY][gridX].y + gridY * 32 + 32
	Timer.tween(0.1, { [self.tiles[gridY][gridX]] = {y = destination} })
end

function Board:eraseBoard()
	for y=1, 8 do
		for x=1, 8 do
			tile = self.tiles[y][x]

			self.tilesInPlay[tile.color][tile.variety] = self.tilesInPlay[tile.color][tile.variety] - 1

			self.tiles[tile.gridY][tile.gridX] = nil
		end
	end
end

--[[
	Shifts down all of the tiles that now have spaces below them, then returns a table that
	contains tweening information for these new tiles.
]]
function Board:getFallingTiles()
	-- tween table, with tiles as keys and their x and y as the to values
	local tweens = {}

	local tileCount = 0

	-- for each column, go up tile by tile till we hit a space
	for x = 1, 8 do
		local space = false
		local spaceY = 0

		local y = 8
		while y >= 1 do

			-- if our last tile was a space...
			local tile = self.tiles[y][x]

			if space then

				-- if the current tile is *not* a space, bring this down to the lowest space
				if tile then

					-- put the tile in the correct spot in the board and fix its grid positions
					self.tiles[spaceY][x] = tile
					tile.gridY = spaceY

					-- set its prior position to nil
					self.tiles[y][x] = nil

					-- tween the Y position to 32 x its grid position
					tweens[tile] = {
						y = (tile.gridY - 1) * 32
					}

					-- set Y to spaceY so we start back from here again
					space = false
					y = spaceY

					-- set this back to 0 so we know we don't have an active space
					spaceY = 0
				end
			elseif tile == nil then
				space = true

				-- if we haven't assigned a space yet, set this to it
				if spaceY == 0 then
					spaceY = y
				end
			end

			y = y - 1
		end
	end

	-- create replacement tiles at the top of the screen
	for x = 1, 8 do
		for y = 8, 1, -1 do
			local tile = self.tiles[y][x]

			if not tile then

				tileCount =  tileCount + 1


				local tile = self:tileCreator(x, y)
				tile.y = -64
				self.tiles[y][x] = tile

				tweens[tile] = {
					y = (tile.gridY - 1) * 32
				}
			end
		end
	end

	return tweens, tileCount
end

function Board:checkIfStuck()
	for y=1,8 do
		for x=1,8 do
			local selectTile = self.tiles[y][x]

			if self.tilesInPlay[selectTile.color][selectTile.variety] >= 3 then

				local adjacentTiles = {}

				if y < 8 then
					table.insert(adjacentTiles, self.tiles[y + 1][x])
				end

				if x < 8 then
					table.insert(adjacentTiles, self.tiles[y][x + 1])
				end

				for k, adjTile in pairs(adjacentTiles) do

					local tempX = selectTile.gridX
					local tempY = selectTile.gridY

					selectTile.gridX = adjTile.gridX
					selectTile.gridY = adjTile.gridY
					adjTile.gridX = tempX
					adjTile.gridY = tempY


					self.tiles[selectTile.gridY][selectTile.gridX] =
						selectTile

					self.tiles[adjTile.gridY][adjTile.gridX] = adjTile


					if self:calculateMatches() ~= false then

						local tempX = selectTile.gridX
						local tempY = selectTile.gridY

						selectTile.gridX = adjTile.gridX
						selectTile.gridY = adjTile.gridY
						adjTile.gridX = tempX
						adjTile.gridY = tempY


						self.tiles[selectTile.gridY][selectTile.gridX] =
							selectTile

						self.tiles[adjTile.gridY][adjTile.gridX] = adjTile
						return false
					else

						local tempX = selectTile.gridX
						local tempY = selectTile.gridY

						selectTile.gridX = adjTile.gridX
						selectTile.gridY = adjTile.gridY
						adjTile.gridX = tempX
						adjTile.gridY = tempY


						self.tiles[selectTile.gridY][selectTile.gridX] =
							selectTile

						self.tiles[adjTile.gridY][adjTile.gridX] = adjTile
					end
				end
			end
		end
	end
	return true
end

function Board:update(dt)
	for y = 1, #self.tiles do
		for x = 1, #self.tiles[1] do
			self.tiles[y][x]:update(dt)
		end
	end
end

function Board:render()
	for y = 1, #self.tiles do
		for x = 1, #self.tiles[1] do
			self.tiles[y][x]:render(self.x, self.y)
		end
	end
end
