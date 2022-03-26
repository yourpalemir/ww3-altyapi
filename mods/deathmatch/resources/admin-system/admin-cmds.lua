locations = {
    igs = {1969, -1760.3857421875, 13.546875},
    ls = {1479.609375, -1696.642578125, 14.046875},
    md = {1178.232421875, -1323.3427734375, 14.109934806824}
}

function aduty(player, cmd)
    if not isDutyOn(player) then
        setElementData(player,'duty', 1)
        outputChatBox('[!] #FFFFFFAdmin-Duty başarıyla açıldı.', player, 255,0,0,true)
    else
        setElementData(player,'duty',0)
        outputChatBox('[!] #FFFFFFAdmin-Duty başarıyla kapatıldı.', player, 255,0,0,true)
    end
end
addCommandHandler('aduty', aduty)

function gotoplace(player, cmd, loc)
    if not loc then
        teleportlocs()
    return end
    if isPlayerAdmin(player) and isDutyOn(player) then 
        if locations[loc] ~= nil then
            setElementPosition(player, unpack(locations[loc]))
        else
            teleportlocs()
        end
    end
end
addCommandHandler('gotoplace',gotoplace)

function teleportlocs()
    outputChatBox('Işınlanabileceğin yerler;',localPlayer,255,255,255,true)
    for k, v in pairs(locations) do
        outputChatBox(tostring(k),localPlayer,255,0,0,true)
    end
end

function getPosition(thePlayer, commandName)
	if (isPlayerDeveloper(thePlayer)) then
		local x, y, z = getElementPosition(thePlayer)
		local rx, ry, rz = getElementRotation(thePlayer)
		local dimension = getElementDimension(thePlayer)
		local interior = getElementInterior(thePlayer)
		
		outputChatBox("Position: " .. x .. ", " .. y .. ", " .. z, thePlayer, 255, 194, 14)
		outputChatBox("Rotation: " .. rx .. ", " .. ry .. ", " .. rz, thePlayer, 255, 194, 14)
		outputChatBox("Dimension: " .. dimension, thePlayer, 255, 194, 14)
		outputChatBox("Interior: " .. interior, thePlayer, 255, 194, 14)
	end
end
addCommandHandler("getpos", getPosition, false, false)