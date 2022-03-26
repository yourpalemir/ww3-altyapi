local sw,sh = guiGetScreenSize()
local font = exports.fonts:getFont('inter',12)

addEventHandler( "onClientRender", root, function (  )
    for k,player in ipairs(getElementsByType("player")) do
        if getElementDimension(getLocalPlayer()) == getElementDimension(player) then
            local x, y, z = getElementPosition(player)
            z = z + 0.95
            local Mx, My, Mz = getCameraMatrix()
            local distance = getDistanceBetweenPoints3D( x, y, z, Mx, My, Mz )
            local size = 1
            if ( distance <= 30 ) then
            local sx,sy = getScreenFromWorldPosition( x, y, z, 0 )
                if ( sx and sy ) then
                    local name = getElementData(localPlayer, 'account:username')
                    local id = ' ('..getElementData(localPlayer, 'dbid')..')' or 0
                    local rank = exports['admin-system']:getPlayerAdminRankByID(localPlayer) 
                    if getElementData(localPlayer,'duty') ~= 1 then
                        dxDrawText(name..id, sx, sy, sx+size, sy+size-10, tocolor(0,0,0,255), size, font, "center", "bottom", false, false, false)
                        dxDrawText(name..id, sx, sy, sx-size, sy-size-10, tocolor(0,0,0,255), size, font, "center", "bottom", false, false, false)
                        dxDrawText(name..id, sx, sy, sx-size, sy+size-10, tocolor(0,0,0,255), size, font, "center", "bottom", false, false, false)
                        dxDrawText(name..id, sx, sy, sx+size, sy-size-10, tocolor(0,0,0,255), size, font, "center", "bottom", false, false, false)
                        dxDrawText(name..id, sx, sy, sx, sy-10, tocolor(255,255,255,255), size, font, "center", "bottom", false, false, false)
                    else
                        dxDrawText(tostring(rank), sx, sy, sx, sy-10, tocolor(255,0,0,255), size, font, "center", "bottom", false, false, false)
                        dxDrawText(name..id, sx, sy, sx+size, sy+size-10, tocolor(0,0,0,255), size, font, "center", "bottom", false, false, false)
                        dxDrawText(name..id, sx, sy, sx-size, sy-size-10, tocolor(0,0,0,255), size, font, "center", "bottom", false, false, false)
                        dxDrawText(name..id, sx, sy, sx-size, sy+size-10, tocolor(0,0,0,255), size, font, "center", "bottom", false, false, false)
                        dxDrawText(name..id, sx, sy, sx+size, sy-size-10, tocolor(0,0,0,255), size, font, "center", "bottom", false, false, false)
                        dxDrawText(name..id, sx, sy, sx, sy-10, tocolor(255,0,0,255), size, font, "center", "bottom", false, false, false)
                    end
                end
            end
        end
    end 
end)