addEventHandler('onPlayerChat', root, function(mesaj, tur)
    if tur == 0 then
        cancelEvent()
        isim = getElementData(source, 'account:username')
        x, y, z = getElementPosition(source)
        nearby = getElementsWithinRange(x, y, z, 5)
        outputChatBox(''..isim..' diyor ki; '..mesaj..'', nearby, 255,255,255, true)
    elseif tur == 1 then
        cancelEvent()
    elseif tur == 2 then
        cancelEvent()
    elseif tur == 3 then
        cancelEvent()
    elseif tur == 4 then
        cancelEvent()
    return end
end)

function duyuru(player, cmd, ...)
    if exports['admin-system']:isPlayerManagement(player) and (exports['admin-system']:isDutyOn(player)) then
        if ... then
            rank = exports['admin-system']:getPlayerAdminRankByID(player)
            isim = getElementData(player, 'account:username')
            mesaj = table.concat({...}, " ")
            outputChatBox('[DUYURU] '..tostring(rank)..' '..isim..':#FFFFFF '..mesaj..'.',root, 255,0,0, true)
        else
            outputChatBox('KULLANIM: /'..cmd..' [yazı]', player)
        end
    end
end
addCommandHandler('duyuru', duyuru)

function ozelmesaj(player, cmd, dbid, ...)
    if tonumber(dbid) then
        target = findPlayer(tonumber(dbid))
        if target then
            data = getElementData(target, 'pm')
            if data == 0 then 
                mesaj = table.concat({...}, " ")
                targetisim = getElementData(target, 'account:username')
                isim = getElementData(target, 'account:username')
                -- target mesaj
                outputChatBox(''..isim..' adlı oyuncudan >> '..mesaj..'.', target, 255,255,153, true)
                -- player mesaj
                outputChatBox(''..targetisim..' adlı oyuncuya >> '..mesaj..'.', player,255,255,153,true)
            else
                outputChatBox('Mesaj göndermek istediğiniz oyuncu özel mesaj kabul etmiyor.', player,255,255,153,true)
            return end
        end
    end
end
addCommandHandler('pm', ozelmesaj)

function pmkapat(player, cmd)
    if exports['admin-system']:isPlayerAdmin(player) then
        if getElementData(player, 'pm') == 0 then
            setElementData(player, 'pm', 1)
            outputChatBox('[!] #FFFFFFArtık özel mesaj kabul etmiyorsun.',player, 255,0, 0,true)
        else
            setElementData(player, 'pm', 0)
            outputChatBox('[!] #FFFFFFArtık özel mesaj kabul ediyorsun.',player, 255,0, 0,true)
        end
    end
end
addCommandHandler('pmkapat', pmkapat)