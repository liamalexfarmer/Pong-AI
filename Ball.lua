--[[Pong Remake GD50

BALL CLASS

Represents the ball which bounces and collides 
to recreate the classic game of pong]]

Ball = Class{}

function Ball:init(x, y, width, height)
	self.x = x
	self.y = y
	self.width = width
	self.height = height
	-- to keep track of the balls velocity:
	self.dy = math.random(2) == 1 and math.random(-100, -50) or math.random(50, 100)
	self.dx = math.random(2) == 1 and math.random(-150, -100) or math.random(100, 150)
	--generates a constant for conservation of momentum
	self.m = math.abs(self.dy) + math.abs(self.dx)
end

function Ball:serve()
	self.dy = math.random(2) == 1 and math.random(-100, -50) or math.random(50,100)
	if servingPlayer == 1 then
		ball.dx = math.random(100, 150)
	else
		ball.dx = math.random(-150, -100)
	end

	self.m = math.abs(self.dy) + math.abs(self.dx)
end

function Ball:collides(paddle)
	if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width then
		return false
	end

	if self.y > paddle.y + paddle.height or paddle.y > self.y + self.height then
		return false
	end

	return true
end
--[[ a function that places the ball in the middle of the play area
with a new random velocity
]]
function Ball:reset()
	self.x = VIRTUAL_WIDTH / 2 - 2
	self.y = VIRTUAL_HEIGHT / 2 + 8
	self.dy = math.random(2) == 1 and math.random(-100, -50) or math.random(50, 100)
	self.dx = math.random(2) == 1 and math.random(-150, -100) or math.random(100, 150)
	self.m = math.abs(self.dy) + math.abs(self.dx)
end

function Ball:update(dt)
	self.x = self.x + self.dx * dt
	self.y = self.y + self.dy * dt
end

function Ball:render()
	love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end