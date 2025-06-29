-- set window size
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- set virtual window size
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- set speed of player's paddle
PADDLE_SPEED = 200

-- library for scaling virtual window to fit window
push = require 'push'

-- library for using class like syntax in lua OOP
Class = require 'class'

require 'ball'
require 'paddle'

function love.load()
    -- set filter to nearest for more pixelated look
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- set screen with virtual screen with push library
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    love.window.setTitle('Pong')

    -- create fonts
    largeFont = love.graphics.newFont('font.ttf', 32)
    mediumFont = love.graphics.newFont('font.ttf', 16)
    smallFont = love.graphics.newFont('font.ttf', 8)

    -- sounds
    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
    }

    love.math.setRandomSeed(os.time())

    -- setup players variables
    player1Score = 0
    player2Score = 0

    player1 = Paddle(10, 10, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 15, VIRTUAL_HEIGHT - 30, 5, 20)

    ball = Ball(VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2, 4, 4)

    servingPlayer = 1
    winningPlayer = 1

    gameState = 'start'
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    
    -- state machine
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'done' then
            gameState = 'serve'
            player1Score = 0
            player2Score = 0
        end
    end
end

function love.update(dt)
    if gameState == 'play' then

        -- check ball collision with player 1
        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.1
            ball.x = player1.x + player1.width
            
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

            sounds['paddle_hit']:play()
        end

        -- check ball collision with player 2
        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.1
            ball.x = player2.x - ball.width
            
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

            sounds['paddle_hit']:play()
        end

        -- check ball collision with top wall
        if ball.y < 0 then
            ball.dy = -ball.dy
            ball.y = 0
            sounds['wall_hit']:play()
        
        -- check ball collision with bottom wall
        elseif ball.y > VIRTUAL_HEIGHT - ball.height then
            ball.dy = -ball.dy
            ball.y = VIRTUAL_HEIGHT - ball.height
            sounds['wall_hit']:play()
        end

        -- check if player 2 scores
        if ball.x < 0 then
            player2Score = player2Score + 1
            if player2Score == 2 then
                winningPlayer = 2
                gameState = 'done'
            else
                gameState = 'serve'
            end

            servingPlayer = 1
            ball:reset()
            sounds['score']:play()

        -- check if player 1 scores
        elseif ball.x + ball.width > VIRTUAL_WIDTH then
            player1Score = player1Score + 1
            if player1Score == 2 then
                winningPlayer = 1
                gameState = 'done'
            else
                gameState = 'serve'
            end

            servingPlayer = 2
            ball:reset()
            sounds['score']:play()

        end

        ball:update(dt)
    end

    -- player 1 movement
    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end

    -- player 2 movement
    if love.keyboard.isDown('up') then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end

    player1:update(dt)
    player2:update(dt)
end

function love.draw()
    push:apply('start')

    -- background color
    love.graphics.clear(40/255, 40/255, 40/255, 1)

    displayFPS()

    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player ' ..tostring(servingPlayer) .. "'s serve!", 0, 10, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then
        -- no UI messages to display
    elseif gameState == 'done' then
        love.graphics.setFont(mediumFont)
        love.graphics.printf('Player ' ..tostring(winningPlayer) .. " wins!", 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
    end

    -- print scores
    love.graphics.setFont(largeFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 2 - 45)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 2 - 45)

    if gameState ~= 'done' then
        -- ball
        ball:render()
    end

    -- paddle 1
    player1:render()

    -- paddle 2
    player2:render()

    push:apply('end')
end

function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
    love.graphics.setColor(1, 1, 1, 1)
end