--[[]
Pong Remake 2020 for GD2018


-Main Program--

Author: Colton Ogden with Additions by Liam Farmer.

Originally Programmed by Atari in 1972, enhanced for programming practice.

]]
--push allows creation of a virtual resolution
push = require "push"

Class = require 'class'

--[ball class, responsible for positioning of the ball]
require 'Ball'

--[paddle class containing universal concepts for paddles]
require 'Paddle'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- speed constant for the movement of paddles; will be multiplied by dt
PADDLE_SPEED = 200

player1Color = {0.5, 0, 1}
player2Color = {0, 0.5, 1}
ballColor = {1, 1, 1}

--[[ 
    Runs the game at startup, used only once.
]]
function love.load()
	--nearest neighbour graphics style, pixelates and removes blurriness
	love.graphics.setDefaultFilter('nearest', 'nearest')

	--provides a random numeric value to avoid repetitiveness with the randomized aspects
	math.randomseed(os.time())

	--initialize a retro font style for the game
	smallFont = love.graphics.newFont('font.ttf', 16)

	--set a larger font setting for the scoreboard
	scoreFont = love.graphics.newFont('font.ttf', 8)

	--set the LOVE2D active font to smallFont
	love.graphics.setFont(smallFont)

	--add sound effects table
	sounds = {
		['paddle1'] = love.audio.newSource('sounds/paddle.wav', 'static'),
		['paddle2'] = love.audio.newSource('sounds/paddle2.wav', 'static'),
		['boundary_hit'] = love.audio.newSource('sounds/boundary.wav', 'static'),
		['goal'] = love.audio.newSource('sounds/goal.wav', 'static'),
		['concede'] = love.audio.newSource('sounds/concede.wav', 'static'),
		['victory'] = love.audio.newSource('sounds/victory.wav', 'static'),
		['defeat'] = love.audio.newSource('sounds/defeat.wav', 'static'),
		['serve'] = love.audio.newSource('sounds/serve.wav', 'static'),
	}

	--initialization sequence for push renered within actual window no matter it's dimensions
	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
	fullscreen = false,
	resizable = false,
	vsync = true
	})

	--we need to initialize some variables for score, and paddle positioning
	player1Score = 0
	player2Score = 0

	--either will be 1 or 2, depending on who last scored
	servingPlayer = math.random(2)
	--starting positions for paddles according to the y axis, preparation for movements
	player1 = Paddle(10, 30, 5, 20)
	player2 = Paddle(VIRTUAL_WIDTH - 15, VIRTUAL_HEIGHT - 30, 5, 20)

	--positional variables for ball at start
	ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 + 8, 4, 4)

	--constant that defines the difficulty. higher values are more difficult
	aiFactor = 50
	--constant addition to ai tracking to add random mistakes based on aiFactor	

	--game state variale used to transition between instances of the game
	gameState = 'start'
end

--[[ Introducing a module to run every frame based on delta-t (dt) as supplies by LOVE2D
]]
function love.update(dt)
	if gameState == 'serve' then
		ball:serve()
		aiError = math.random(-math.floor(ball.m/aiFactor), math.floor(ball.m/aiFactor))
	elseif gameState == 'play' then
		if ball:collides(player1) then
			--player 1 paddle sound
			sounds['paddle1']:play()
			--[[ introduces momentum into the system, if dx is negative, make it positive
			add a random based on 0-10% of conservation of momentum constant ball.m.
			If not, make it negative and substract same randomized function
			]]
			if ball.dx < 0 then
				ball.dx = -ball.dx + math.random(math.floor(ball.m * 0.1))
			else
				ball.dx = -ball.dx - math.random(math.floor(ball.m * 0.1))
			end
			--place ball as before
			ball.x = player1.x + player1.width
			--incrementally increase the overall directional velocity allowance
			ball.m = ball.m * 1.05

			--use absolute value to remove x directionality from y calculation
			--if ball.dy is negative, we maintain it's directionality while
			--altering it's velocity based on dx, which has been increased by a random amount.
			--if else only required to maintain directionality
			--this all ensures ball.dx + ball.dy = ball.m, so velocity increases linearly
			--but the directionality more randomly (while still feeling natural and realistic).
			--starting code had a tendency to introduce unrealistic feeling ricochets
			if ball.dy < 0 then
				ball.dy = (ball.m - math.abs(ball.dx)) * -1
			else
				ball.dy = ball.m - math.abs(ball.dx)
			end
		end

		if ball:collides(player2) then
			--player 2 paddle sound
			sounds['paddle2']:play()
			--reverse x direction if collided and
			--set the right side of the ball to the left side of the paddle
			if ball.dx < 0 then
				ball.dx = -ball.dx + math.random(math.floor(ball.m * 0.1))
			else
				ball.dx = -ball.dx - math.random(math.floor(ball.m * 0.1))
			end

			ball.x = player2.x - ball.width
			ball.m = ball.m * 1.05
			aiError = math.random(-math.floor(ball.m/aiFactor), math.floor(ball.m/aiFactor))

			--keeps y axis direction consistent but randomized

			if ball.dy < 0 then
				ball.dy = (ball.m - math.abs(ball.dx)) * -1
			else
				ball.dy = ball.m - math.abs(ball.dx)
			end
		end

		-- if the ball's y axis is equal to or less than the top framing,
		--reverse the direction of dy
		if ball.y <= 19 then
			ball.y = 19
			ball.dy = -ball.dy
			sounds['boundary_hit']:play()
		end

		--if the ball top left corner is higher 'y' than the height of the 
		--window minus the size of the ball, reverse dy and set the balls
		--position to be touching the bottom frame
		if ball.y >= VIRTUAL_HEIGHT - 4 then
			ball.y = VIRTUAL_HEIGHT - 4
			ball.dy = -ball.dy
			sounds['boundary_hit']:play()
		end
	end

	if ball.x < -2 then
		sounds['concede']:play()
		ball:reset()
		servingPlayer = 1
		player2Score = player2Score + 1
		if player2Score == 10 then
			winningPlayer = 2
			gameState = 'done'
			sounds['defeat']:play()
		else
			gameState = 'serve'
		end
	end

	if ball.x > VIRTUAL_WIDTH then
		sounds['goal']:play()
		ball:reset()
		servingPlayer = 2
		player1Score = player1Score + 1
		if player1Score == 10 then
			winningPlayer = 1
			gameState = 'done'
			sounds['victory']:play()
		else
			gameState = 'serve'
		end
	end



	--setup player 1 movements
	if love.keyboard.isDown('w') then 
		player1.dy = -PADDLE_SPEED
	elseif love.keyboard.isDown('s') then
		player1.dy = PADDLE_SPEED
	else
		player1.dy = 0
	end

	--setup player 2 movements
	if ball.dx <= 0 or ball.dy == 0 then
		player2.dy = 0
	else
		if ball.x > VIRTUAL_WIDTH / 2 and ball.y + aiError > player2.y + ball.height + (player2.height / 2) then
			player2.dy = PADDLE_SPEED
		elseif ball.x > VIRTUAL_WIDTH / 2 and ball.y + ball.height + aiError < player2.y - ball.height + (player2.height / 2) then
			player2.dy = -PADDLE_SPEED
		else
			player2.dy = 0
		end
	--elseif ball.dx < 0 then
		--if player2.y < VIRTUAL_HEIGHT / 2 then
		--	player2.dy = PADDLE_SPEED / 2
		--elseif player2.y + player2.height > VIRTUAL_HEIGHT / 2 + 10 + (player2.height / 2) then
		--	player2.dy = -PADDLE_SPEED / 2
		--else
		--	player2.dy = 0
		--end
	end


	--make the ball update based on delta equations if we're on play state;
	--scaling velocity by dt makes movement framerate-independent
	if gameState == 'play' then
		ball:update(dt)
	end

	player1:update(dt)
	player2:update(dt)
end

--[[
	Quits the game on user escape input. Function parses every frame.
]]
function love.keypressed(key)
	--use strings for key name
	if key == 'escape' then
		love.event.quit()
	elseif key == 'enter' or key == 'return' then
		if gameState == 'start' then
			gameState = 'serve'
		elseif gameState == 'serve' then
			sounds['serve']:play()
			gameState = 'play'
		elseif gameState == 'done' then
			gameState = 'serve'
			ball:reset()
			player1Score = 0
			player2Score = 0

			if winningPlayer == 1 then
				servingPlayer = 2
			else 
				servingPlayer = 1
			end
		end
	end
end


--[[
Making Text Appear on Screen, drawn by said function
]]

function love.draw()
	--Begins the rendering of virtual resolution
	push:start()

	--set the background color of the screen in R, G, B, %Opacity
	love.graphics.clear(0.025, 0.01, 0.05, 255)
	displayScore()
	--print welcome message on top of page
	love.graphics.setFont(smallFont)
	love.graphics.printf('PONG', 0, 2, VIRTUAL_WIDTH, 'center')

	--conditional Text
	if gameState == 'start' then
		love.graphics.printf('Press Enter to Begin!', scoreFont, 0,	VIRTUAL_HEIGHT / 3, VIRTUAL_WIDTH, 'center')
	elseif gameState == 'serve' then
		love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s Serve!", scoreFont, 0, 
			VIRTUAL_HEIGHT / 3, VIRTUAL_WIDTH, 'center')
		love.graphics.printf('Press Enter to Serve', scoreFont, 0, VIRTUAL_HEIGHT / 3 + 10, VIRTUAL_WIDTH, 'center')
	elseif gameState == 'play' then
		--no ui messages should show
	elseif gameState == 'done' then
		love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!', smallFont, 0,
			VIRTUAL_HEIGHT / 3, VIRTUAL_WIDTH, 'center')
		love.graphics.printf('Press Enter to Play Again', scoreFont, 0,
			VIRTUAL_HEIGHT / 3 + 15, VIRTUAL_WIDTH, 'center')
	end

	--render framing underline for the title
	love.graphics.rectangle('fill', 5, 19, VIRTUAL_WIDTH - 10, 1)

	--render paddles in respective colors
	love.graphics.setColor(player1Color)
	player1:render()

	love.graphics.setColor(player2Color)
	player2:render()

	-- render the ball in the center
	love.graphics.setColor(ballColor)
	ball:render()

	displayFPS()
	-- end the virtual rendering system
	push:finish()
end

--Renders current displayFPS

function displayFPS()
	love.graphics.setFont(scoreFont)
	love.graphics.setColor(1, 1, 1, 0.5)
	love.graphics.print('FPS: '.. tostring(love.timer.getFPS()), VIRTUAL_WIDTH / 2 - 9, VIRTUAL_HEIGHT - 10)
end

function displayScore()
	love.graphics.setFont(scoreFont)
	love.graphics.print('Player 1: ' .. tostring(player1Score), 20, 10)
	love.graphics.print('Player 2: ' ..  tostring(player2Score), VIRTUAL_WIDTH - 65, 10)
end

