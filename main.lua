local Level = require("game.Level")

function love.load()
	g_defaultWidth, g_defaultHeight = 640, 360

	g_windowWidth, g_windowHeight = g_defaultWidth, g_defaultHeight

	g_viewX, g_viewY = 0, 0

	g_coordStackReady = false

	g_currentLevel = nil

	g_currentFont = nil
	g_currentSmallFont = nil
	g_currentTinyFont = nil

	g_currentLevelN = 1

	g_gameComplete = false

	g_Sounds = nil

	function xc(coord)
		return g_windowWidth / g_defaultWidth * coord
	end

	function yc(coord)
		return g_windowHeight / g_defaultHeight * coord
	end

	g_fonts = {
		normal = love.graphics.newFont("assets/PressStart2P.ttf", 8),
	}
	--[[
	g_currentFont = love.graphics.newFont("assets/PressStart2P.ttf", 30)
	g_currentSmallFont = love.graphics.newFont("assets/PressStart2P.ttf", 20)
	g_currentTinyFont = love.graphics.newFont("assets/PressStart2P.ttf", 8)
	--]]

	love.window.setMode(g_defaultWidth, g_defaultHeight, {
		fullscreen = true,
		fullscreentype = "desktop",
		msaa = 2
	})
	love.resize(love.window.getMode())
	--love.graphics.setDefaultFilter("linear", "nearest", 0)
	love.graphics.setBackgroundColor(240, 240, 200)
	love.graphics.setBlendMode("alpha")
	love.mouse.setVisible(false)

	--love.graphics.setFont(g_currentFont)

	g_currentLevel = Level:new{}
	--love.audio.play(g_sounds.start)
end

function love.resize(w, h)
	g_windowWidth, g_windowHeight = w, h
end

local dtotal = 0
function love.update(dt)
	-- If user presses Esc then quit
	if love.keyboard.isScancodeDown('escape') or love.keyboard.isDown('q') then
		love.event.quit()
	end

	-- Limit to 1/60 updates
	dtotal = dtotal + dt
	if dtotal >= 1/60 then
		dtotal = dtotal - 1/60
	else
		return
	end

	-- If level completed load and begin next level
	if g_currentLevel.success then
		g_currentLevelN = g_currentLevelN + 1
		local newSource = _G["g_levelData"..g_currentLevelN]
		local newExtra = _G["g_levelExtra"..g_currentLevelN]
		if not newSource then
			g_gameComplete = true
		else
			g_currentLevel = Level:new{}
		end
	end

	-- If level restart requested then restart the level
	if love.keyboard.isDown('r') then
		g_currentLevel = Level:new{}
	end
	if not g_gameComplete then
		g_currentLevel:step()
	end
end

function love.draw()
	-- Setup view coordinates
	local xFac = g_windowWidth/g_defaultWidth
	local yFac = g_windowHeight/g_defaultHeight
	local shrink, aScale, aWidth, aHeight, screenX, screenY, barSize
	if xFac < yFac then
		shrink = "y"
		aWidth = g_windowWidth
		aHeight = xFac/yFac * g_windowHeight
		local shrinkSpace = g_windowHeight - aHeight
		barSize = shrinkSpace/2
		screenX = 0
		screenY = barSize
		aScale = xFac
	else
		shrink = "x"
		aWidth = yFac/xFac * g_windowWidth
		aHeight = g_windowHeight
		local shrinkSpace = g_windowWidth - aWidth
		barSize = shrinkSpace/2
		screenX = barSize
		screenY = 0
		aScale = yFac
	end
	love.graphics.push()
	love.graphics.translate(screenX, screenY)
	love.graphics.push()
	love.graphics.scale(aScale, aScale)

	if g_gameComplete then
		love.graphics.setColor(0,0,0)
		--love.graphics.setFont(g_currentSmallFont)
		love.graphics.print("thanks for playing :)", 10, 100)
	else
		g_currentLevel:draw()
	end

	love.graphics.pop()
	love.graphics.pop()
	love.graphics.setColor(0, 0, 0)
	if shrink == "y" then
		love.graphics.rectangle("fill", 0, 0, g_windowWidth, barSize)
		love.graphics.rectangle("fill", 0, g_windowHeight - barSize, g_windowWidth, barSize)
	else
		love.graphics.rectangle("fill", 0, 0, barSize, g_windowHeight)
		love.graphics.rectangle("fill", g_windowWidth - barSize, 0, barSize, g_windowHeight)
	end
end
