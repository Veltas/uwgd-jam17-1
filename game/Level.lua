local Level = {}
Level.Level = true

function Level.new(class, self)
	setmetatable(self, {__index = class})
	if type(self) ~= "table" then
		error("Expected a table", 2)
	end

	love.physics.setMeter(1)
	self.world = love.physics.newWorld(0, 10)
	self.player = {
		body = love.physics.newBody(self.world, 0, -2, "dynamic"),
	}
	self.player.fix = love.physics.newFixture(self.player.body, love.physics.newCircleShape(1), 1)

	self.statics = {}
	local newStatic = {
		body = love.physics.newBody(self.world, 0, 2, "static"),
		w = 5,
		h = 1,
	}
	newStatic.fix = love.physics.newFixture(newStatic.body, love.physics.newRectangleShape(newStatic.w, newStatic.h))
	table.insert(self.statics, newStatic)

	-- start view on player
	local playerX, playerY = self.player.body:getPosition()
	g_viewX, g_viewY = playerX - 0.5*g_defaultWidth, playerY - 0.5*g_defaultHeight

	return self
end

function Level:step()
	-- handle user movement input (while game not over)
	self.world:update(1/60)
end

function Level:draw()
	love.graphics.push()
	love.graphics.translate(-g_viewX, -g_viewY)
	love.graphics.scale(50)

	-- draw environment
	love.graphics.setColor(10, 60, 10)
	local pX, pY = self.player.body:getPosition()
	local pR = self.player.fix:getShape():getRadius()
	love.graphics.circle("fill", pX, pY, pR, 50)

	love.graphics.setColor(30, 30, 30)
	for _, static in ipairs(self.statics) do
		local sX, sY = static.body:getPosition()
		love.graphics.rectangle("fill", sX - static.w/2, sY - static.h/2, static.w, static.h)
	end

	--[[
	love.graphics.setColor(40, 40, 40)
	local wallGrid = self.wallGrid
	for j, row in ipairs(wallGrid) do
		for i, occupied in ipairs(row) do
			if occupied then
				love.graphics.rectangle("fill", (i - 1) * g_tileSize, (j - 1) * g_tileSize, g_tileSize, g_tileSize)
			end
		end
	end
	--]]

	love.graphics.pop()

	-- draw on screen
end

return Level
