--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The Selection class gives us a list of textual items that link to callbacks;
    this particular implementation only has one dimension of items (vertically),
    but a more robust implementation might include columns as well for a more
    grid-like selection, as seen in many kinds of interfaces and games.
]]

Selection = Class{}

function Selection:init(def)
    self.items = def.items
    self.x = def.x
    self.y = def.y

    self.height = def.height
    self.width = def.width
    self.font = def.font or gFonts['small']

    self.gapHeight = self.height / #self.items

    self.cursorEnabled = def.cursorEnabled
    if self.cursorEnabled == nil then self.cursorEnabled = true end
    self.currentSelection = 1
end

function Selection:update(dt)
    if self.cursorEnabled then
        if love.keyboard.wasPressed(CTRL_UP) then
            if self.currentSelection == 1 then
                self.currentSelection = #self.items
            else
                self.currentSelection = self.currentSelection - 1
            end

            gSounds['blip']:stop()
            gSounds['blip']:play()
        elseif love.keyboard.wasPressed(CTRL_DOWN) then
            if self.currentSelection == #self.items then
                self.currentSelection = 1
            else
                self.currentSelection = self.currentSelection + 1
            end

            gSounds['blip']:stop()
            gSounds['blip']:play()
        elseif love.keyboard.wasPressed(CTRL_OK) then
            self.items[self.currentSelection].onSelect()

            gSounds['blip']:stop()
            gSounds['blip']:play()
        end
    end
end

function Selection:render()
    local currentY = self.y

    for i = 1, #self.items do
        local paddedY = currentY + (self.gapHeight / 2) - self.font:getHeight() / 2

        if i == self.currentSelection and self.cursorEnabled then
            love.graphics.draw(gTextures['cursor'], self.x - 8, paddedY)
        end

        love.graphics.printf(' ' .. self.items[i].text, self.x, paddedY, self.width, 'left')

        currentY = currentY + self.gapHeight
    end
end
