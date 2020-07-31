--[[
    ScoreState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    A simple state used to display the player's score before they
    transition back into the play state. Transitioned to from the
    PlayState when they collide with a Pipe.
]]

ScoreState = Class{__includes = BaseState}

-- intialize trophy sprites
local TROPHY_BRONZE = love.graphics.newImage('goblet/goblet_bronze.png')
local TROPHY_SILVER = love.graphics.newImage('goblet/goblet_silver.png')
local TROPHY_GOLD   = love.graphics.newImage('goblet/goblet_gold.png')

--[[
    When we enter the score state, we expect to receive the score
    from the play state so we know what to render to the State.
]]
function ScoreState:enter(params)
    self.score = params.score

    -- set the correct trophy
    if self.score < 5 then
        trophy = TROPHY_BRONZE
    elseif self.score < 10 then
        trophy = TROPHY_SILVER
    else
        trophy = TROPHY_GOLD
    end
end

function ScoreState:update(dt)
    -- go back to play if enter is pressed
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('countdown')
    end
end

function ScoreState:render()
    -- simply render the score to the middle of the screen
    love.graphics.setFont(flappyFont)
    love.graphics.printf('Oof! You lost!', 0, 64, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(mediumFont)
    love.graphics.printf('Score: ' .. tostring(self.score), 0, 100, VIRTUAL_WIDTH, 'center')

    love.graphics.printf('Press Enter to Play Again!', 0, 160, VIRTUAL_WIDTH, 'center')

    -- render trophy 
    love.graphics.draw(trophy, VIRTUAL_WIDTH/2 - trophy:getWidth()/2, 180)
end