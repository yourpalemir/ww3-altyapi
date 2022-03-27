locations = {
    igs = {1969, -1760.3857421875, 13.546875},
    ls = {1479.609375, -1696.642578125, 14.046875},
    md = {1178.232421875, -1323.3427734375, 14.109934806824}
}

db = exports.sqlite:getConnection()

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

function setSkin(player,cmd,dbid,id)
    if isPlayerAdmin2(player) then
    targetP = exports.main:findPlayer(dbid)
    if tonumber(dbid) and tonumber(id) then
        if (targetP) then
            setElementModel(targetP, tonumber(id))
            outputChatBox("[!] #FFFFFF"..getPlayerAdminRankByID(player).." "..getElementData(player, 'account:username').." adlı yetkili tarafından skininiz "..id.."ID'ye çevirildi.", targetP, 255,0,0,true) 
            outputChatBox("[!] #FFFFFF"..getElementData(targetP, 'account:username').." adlı oyuncunun skinini "..id.."ID'ye çevirdiniz.",player, 255,0,0,true)
        end
    else
        outputChatBox('KULLANIM: /'..cmd..' [dbid] [skinid]', player)
    end
    end
end
addCommandHandler('setskin',setSkin)

function adminver(player, cmd, dbid, rank)
    if isPlayerDeveloper(player) then
        targetP = exports.main:findPlayer(dbid)
        if tonumber(dbid) and tonumber(rank) then
            if (targetP) then
                setElementData(targetP, 'adminlevel', tonumber(rank))
                dbExec(db, 'UPDATE accounts SET admin=? WHERE id=?', tonumber(rank), tonumber(getElementData(targetP,'dbid')))
                -- target
                outputChatBox('[!] '..getPlayerAdminRankByID(player)..' '..getElementData(targetP, 'account:username')..' #FFFFFFadlı yetkili tarafından admin seviyeniz '..getAdminRankByID(tonumber(rank))..' adlı yetkiye yükseltildi.',targetP,255,0,0,true)
                -- player
                outputChatBox('[!] #FFFFFF'..getElementData(targetP, 'account:username')..' adlı oyuncunun admin seviyesini '..getAdminRankByID(tonumber(rank))..' seviyesine çevirdiniz.', player, 255,0,0,true)
            end
        else
            outputChatBox('KULLANIM: /'..cmd..' [dbid] [rankid]', player, 255,255,153,true)
        return end
    end
end
addCommandHandler('adminver', adminver)