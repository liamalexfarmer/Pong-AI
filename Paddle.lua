--[[

Paddle Class

Reperesents the paddle of a player paddle in a modern remake
of the retro classic PONG.
]]

Paddle = Class{}

--allows us to assign the Paddle Class as a variable
--e.g. player1 = Paddle(10, 30, 5, 20)
--any of these variables can be recalled and altered e.g. player1.dy = 10
function Paddle:init(x, y, width, height)
	self.x = x
	self.y = y
	self.width = width
	self.height = height
	self.dy = 0
end

function Paddle:update(dt)
	if self.dy < 0 then
		self.y = math.max(21, self.y + self.dy * dt)
	else
		self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.dy * dt)
	end
end

function Paddle:render()
	love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end
