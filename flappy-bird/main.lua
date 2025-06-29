-- library for scaling virtual window to fit window
push = require 'push'

-- set window size
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- set virtual window size
VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

local backgroundScroll = 0

local groundScroll = 0

local BACKGROUND_SCROLL_SPEED = 30
local GROUND_SCROLL_SPEED = 60


function love.load()
    -- set filter to nearest for more pixelated look
    love.graphics.setDefaultFilter('nearest', 'nearest')

    background = love.graphics.newImage('background.png')
    ground = love.graphics.newImage('ground.png')

    love.window.setTitle('Flappy Bird')

    -- set screen with virtual screen with push library
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
end

function love.draw()
    push:apply('start')

    love.graphics.draw(background, 0, 0)

    love.graphics.draw(ground, 0, VIRTUAL_HEIGHT - 16)

    push:apply('end')
end