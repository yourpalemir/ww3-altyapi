-- == Radar fixed by Lightning! (vk.com/lightning288) == --

local screenW, screenH = guiGetScreenSize()
local zoom = 1
if screenW < 1920 then
    zoom = math.min(2, 1920 / screenW)
end

local radar = 
{
	x = 60/zoom,
	y = 750/zoom,
	width  = 280/zoom,
	height = 270/zoom,
}

local map = 
{
	left = 2303, right = 1997, top = 1500, bottom = 1500,
	scale = 0.5,
}

local blipSize = 
{
	size = 24,
	markerSize = 8,
}

local delayingBlipIcons = {
	[7] = true,
	[17] = true,
	[41] = true,
	[56] = true,
}

radar.halfWidth, radar.halfHeight = radar.width/2, radar.height/2

radar.center = 
{
	x = radar.x+radar.halfWidth,
	y = radar.y+radar.halfHeight,
}

map.width, map.height = map.left+map.right, map.top+map.bottom
map.centerShiftX, map.centerShiftY = (map.left - map.right)/2, (map.top - map.bottom)/2

blipSize.halfSize = blipSize.size/2
blipSize.halfMarkerSize = blipSize.markerSize/2

local texture = {
	water = dxCreateTexture("assets/images/blip/water.png", "dxt1", true, "clamp"),
	radar = dxCreateTexture("assets/images/blip/radar.dds", "dxt1", true, "clamp"),
}

function getCameraParameters()
	local camera = {}
	camera.element = getCamera()
	_, _, camera.rot = getElementRotation(camera.element)
	camera.x, camera.y, camera.z = getCameraMatrix ()
	local radianRotation = math.rad(camera.rot)
	camera.sin = math.sin(radianRotation)
	camera.cos = math.cos(radianRotation)
	return camera
end

function getTargetParameters()
	local target = {}
	target.element = getPedOccupiedVehicle( localPlayer ) or localPlayer
	if (target.element) then
		target.x, target.y, target.z = getElementPosition(target.element)
		_, _, target.rot = getElementRotation(target.element)
		local spX, spY, spZ = getElementVelocity(target.element)
		target.speed = (spX^2 + spY^2 + spZ^2)^(0.5)*180
	else
		target.x, target.y, target.z = getCameraMatrix()
		target.rot = 0
		target.speed = 0
	end
	target.mapX = -target.x*map.scale-map.left
	target.mapY =  target.y*map.scale-map.top
	return target
end

function dxDrawCircle(x, y, width, height, color, angleStart, angleSweep, borderWidth)
    local circleShader = dxCreateShader("assets/shader/hou_circle.fx")
	if angleSweep < 360 then
		angleEnd = math.fmod(angleStart + angleSweep, 360)
	else
		angleStart = 0
		angleEnd = 360
	end
	dxSetShaderValue(circleShader, "sCircleWidthInPixel", width)
	dxSetShaderValue(circleShader, "sCircleHeightInPixel", height)
	dxSetShaderValue(circleShader, "sBorderWidthInPixel", borderWidth)
	dxSetShaderValue(circleShader, "sAngleStart", math.rad(angleStart) - math.pi)
	dxSetShaderValue(circleShader, "sAngleEnd", math.rad(angleEnd) - math.pi)
	dxDrawImage(x, y, width, height, circleShader, 0, 0, 0, color)
end

local radarRenderTarget = dxCreateRenderTarget(radar.width, radar.height, true)
local maskShader = dxCreateShader("assets/shader/mask3d.fx")
local maskTexture = dxCreateTexture("assets/images/radar/mask.png")
		
function renderRadar()
	if (maskTexture) and (getElementInterior(localPlayer) == 0) then
		local camera = getCameraParameters()
		local target = getTargetParameters()
		local zoom = 1.0
        maskShader:setValue("gTexture", radarRenderTarget)
	    maskShader:setValue("gUVPosition", 0, 0)
	    maskShader:setValue("gUVScale", 1, 1)
	    maskShader:setValue("gUVRotCenter", 0.5, 0.5)
	    maskShader:setValue("sPicTexture", radarRenderTarget)
	    maskShader:setValue("sMaskTexture", maskTexture)
		dxSetRenderTarget(radarRenderTarget, true)
		dxDrawImage(0, 0, radar.width, radar.height, texture.water)
		dxDrawImage(target.mapX*zoom + radar.halfWidth, target.mapY*zoom + radar.halfHeight,
		map.width*zoom, map.height*zoom,
		texture.radar, camera.rot,
		(target.x*map.scale + map.centerShiftX)*zoom, (-target.y*map.scale + map.centerShiftY)*zoom)
		dxSetRenderTarget()
		dxDrawImage(radar.x, radar.y, radar.width, radar.height, maskShader)
		dxDrawCircle(radar.x, radar.y, radar.width, radar.height, tocolor(0,0,0,100), 0, 360, 10)
		dxDrawCircle(radar.x, radar.y, radar.width, radar.height, tocolor(0,0,0,255), 0, getElementHealth(localPlayer)/100*360, 10)
		-- Рисуем блипы
		local delayedBlips = {}		
		for _, blip in ipairs(getElementsByType("blip")) do
			if (not delayingBlipIcons[ getBlipIcon(blip) ]) then	
				local x, y, z = getElementPosition(blip)
				local maxDistance = getBlipVisibleDistance(blip)			
				if (getDistanceBetweenPoints2D(target.x, target.y, x, y) < maxDistance) and (getElementAttachedTo(blip) ~= localPlayer) then
					drawBlipOnMap(blip, camera, target, zoom)
				end
			else
				table.insert(delayedBlips, blip)
			end
		end
		-- Рисуем важные блипы поверх всех остальных
		for _, blip in ipairs(delayedBlips) do
			drawBlipOnMap(blip, camera, target, zoom)
		end
		-- Рисуем блип игрока/цели
		if (target.element) then
			dxDrawImage(radar.center.x-blipSize.halfSize, radar.center.y-blipSize.halfSize, blipSize.size, blipSize.size, "assets/images/blip/2.png", camera.rot-target.rot)
		else
			dxDrawImage(radar.center.x-blipSize.halfSize, radar.center.y-blipSize.halfSize, blipSize.size, blipSize.size, "assets/images/blip/64.png", 0)
		end
	end
end

function drawBlipOnMap(blip, camera, target, zoom)
	local icon = getBlipIcon(blip)
	local x, y, z = getElementPosition(blip)
	local xShift = (x-target.x)*map.scale*zoom
	local yShift = (target.y-y)*map.scale*zoom
	local blipPosX = xShift*camera.cos - yShift*camera.sin
	local blipPosY = xShift*camera.sin + yShift*camera.cos
	if getDistanceBetweenPoints2D(x, y, 0, 0) > -radar.halfWidth then
		blipPosX, blipPosY = repairCoordinates(blipPosX, blipPosY, camera)
	end
	
	if (icon > 0) then
		dxDrawImage(radar.center.x + blipPosX - blipSize.halfSize,
					radar.center.y + blipPosY - blipSize.halfSize,
					blipSize.size, blipSize.size, "assets/images/blip/"..icon..".png")
	else
		local r, g, b = getBlipColor(blip)
		local size = getBlipSize(blip)
		if (z-target.z > 5) then
			icon = "up"
		elseif (z-target.z < -5) then
			icon = "down"
		end
		dxDrawImage(radar.center.x + blipPosX - blipSize.halfMarkerSize*size,
					radar.center.y + blipPosY - blipSize.halfMarkerSize*size,
					blipSize.markerSize*size, blipSize.markerSize*size,"assets/images/blip/"..icon..".png", 0, 0, 0, tocolor(r, g, b) )
	end
end

local function findRotation(x1, y1, x2, y2)
	local rotation = -math.deg(math.atan2(x2-x1 ,y2-y1))
	if rotation < 0 then
	    rotation = rotation + 360 
	end
	return rotation
end

local function getDistanceRotation(x, y, dist, angle)
	local a = math.rad(90 - angle)
	local dx = math.cos(a) * dist
	local dy = math.sin(a) * dist
	return x+dx, y+dy
end

function repairCoordinates(blipPosX, blipPosY, blip)
	local radius = 135/zoom
	local newX, newY = blipPosX, blipPosY
	local angle = -findRotation(0, 0, blipPosX, blipPosY)
	local px,py = getDistanceRotation(radar.center.x, radar.center.y, radius, angle)
	local name = getDistanceBetweenPoints2D(blipPosX, blipPosY, 0, 0)
	if name > radius then
		newX = px - radar.center.x
		newY = py - radar.center.y
	end
	return newX, newY
end

local allowedToWork
function startWork(key)
	setPlayerHudComponentVisible("radar", false)
	bindKey("F11", "up", function()
		toggleRadar()
	end)
	toggleRadar(true)
	allowedToWork = true
end

local radarIsVisible = false
function toggleRadar(state)
	if (state == true) and (not radarIsVisible) then
		addEventHandler('onClientHUDRender', root, renderRadar)
		radarIsVisible = true
	elseif (state == false) and (radarIsVisible) then
		removeEventHandler('onClientHUDRender', root, renderRadar)
		radarIsVisible = false
	else
		toggleRadar(not radarIsVisible)
	end
end

addEventHandler("onClientResourceStop", resourceRoot, function()
	setPlayerHudComponentVisible("radar", true)
end)

local showPlayers
local playerBlips = {}

addEventHandler("onClientResourceStart", resourceRoot, function()
	if fileExists("showPlayers/false") then
		showPlayers = false
	elseif fileExists("showPlayers/true") then
		showPlayers = true
	else
		showPlayers = "near"
	end
	refreshPlayerBlips()
end)

function refreshPlayerBlips()
	for i, blip in pairs(playerBlips) do
		if isElement(blip) then destroyElement(blip) end
		playerBlips[i] = nil
	end
	if (showPlayers == "near") then
		for _, player in ipairs( getElementsByType("player") ) do
			local r,g,b = getPlayerNametagColor(player)
			playerBlips[player] = createBlipAttachedTo(player, 0, 2, r, g, b, 255, 0, 500)
		end
	elseif (showPlayers) then
		for _, player in ipairs( getElementsByType("player") ) do
			local r,g,b = getPlayerNametagColor(player)
			playerBlips[player] = createBlipAttachedTo(player, 0, 2, r, g, b)
		end
	else
		local r,g,b = getPlayerNametagColor(localPlayer)
		playerBlips[localPlayer] = createBlipAttachedTo(localPlayer, 0, 2, r, g, b)
	end
end

function createBlipForPlayer(player)
	if isElement(player) then
		local r,g,b = getPlayerNametagColor(player)
		if (showPlayers == "near") then
			playerBlips[player] = createBlipAttachedTo(player, 0, 2, r, g, b, 255, 0, 500)
		elseif (showPlayers) then
			playerBlips[player] = createBlipAttachedTo(player, 0, 2, r, g, b)
		end
	end
end

addEventHandler("onClientPlayerJoin", root, function()
	setTimer(createBlipForPlayer, 1000, 1, source)
end)

addEventHandler("onClientPlayerQuit", root, function()
	if isElement(playerBlips[source]) then destroyElement(playerBlips[source]) end
end)

function togglePlayerBlips()
	if (not allowedToWork) then return end
	if (showPlayers == "near") then
		if fileExists("showPlayers/true") then fileDelete("showPlayers/true") end
		fileClose(fileCreate("showPlayers/false"))
		showPlayers = false
		refreshPlayerBlips()
		outputChatBox("Показ игроков на карте отключен.", 30,255,30)

	elseif (showPlayers) then
		if fileExists("showPlayers/true") then fileDelete("showPlayers/true") end
		showPlayers = "near"
		refreshPlayerBlips()
		outputChatBox("Показ игроков на карте включен в ограниченном радиусе.", 30,255,30)

	else
		if fileExists("showPlayers/false") then fileDelete("showPlayers/false") end
		fileClose(fileCreate("showPlayers/true"))
		showPlayers = true
		refreshPlayerBlips()
		outputChatBox("Показ игроков на карте включен.", 30,255,30)

	end
end
addCommandHandler("players", togglePlayerBlips, false)

function playersShowType()
	return showPlayers
end

function getRadarCoords()
	return radar.x, radar.y, radar.width, radar.height
end

local chaseColorDelta = 20
local radiusColorDelta = 5
local restoreDelta = 10
local white = tocolor(255,255,255)
local customAnimation = false
local hasPolicemenInRadius, hasChase = false, false
local currentColor = {255, 255, 255}
local colorPhase = 1

function getRadarBorderColor()
	if (not customAnimation) then
		return white
	else
		if (hasChase) then
			if (colorPhase == 2) then
				local color = math.min(math.min(currentColor[1], currentColor[2]) + chaseColorDelta, 255)
				currentColor = {color, color, 255}
				if (color == 255) then
					colorPhase = 3
				end
				return tocolor(unpack(currentColor))

			elseif (colorPhase == 3) then
				local color = math.max(math.min(currentColor[2], currentColor[3]) - chaseColorDelta, 0)
				currentColor = {255, color, color}
				if (color == 0) then
					colorPhase = 4
				end
				return tocolor(unpack(currentColor))

			elseif (colorPhase == 4) then
				local color = math.min(math.min(currentColor[2], currentColor[3]) + chaseColorDelta, 255)
				currentColor = {255, color, color}
				if (color == 255) then
					colorPhase = 1
				end
				return tocolor(unpack(currentColor))

			else
				local color = math.max(math.min(currentColor[1], currentColor[2]) - chaseColorDelta, 0)
				currentColor = {color, color, 255}
				if (color == 0) then
					colorPhase = 2
				end
				return tocolor(unpack(currentColor))
			end

			elseif (hasPolicemenInRadius) then
			if (colorPhase == 4) then
				local b = math.min(currentColor[3] + radiusColorDelta, 255)
				local g = 255 - (255-b)/2
				currentColor = {255, g, b}
				if (b == 255) then
					colorPhase = 3
				end
				return tocolor(unpack(currentColor))
			else
				local b = math.max(currentColor[3] - radiusColorDelta, 0)
				local g = 255 - (255-b)/2
				currentColor = {255, g, b}
				if (b == 0) then
					colorPhase = 4
				end
				return tocolor(unpack(currentColor))
			end
		else
			currentColor = 
			{
				math.min(255, currentColor[1]+restoreDelta),
				math.min(255, currentColor[2]+restoreDelta),
				math.min(255, currentColor[3]+restoreDelta),
			}
			
			if (currentColor[1] == 255) and (currentColor[2] == 255) and (currentColor[3] == 255) then
				customAnimation = false
				return white
			else
				return tocolor(unpack(currentColor))
			end
		end
	end
end
startWork()