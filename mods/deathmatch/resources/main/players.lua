function isPlayer(player)
    if player and isElement(player) and getElementType(player) == 'player' then
        return true
    end
end

function findPlayer(dbid)
    for k, v in pairs(getElementsByType('player')) do
        vdata = getElementData(v, 'dbid')
        if tonumber(vdata) == tonumber(dbid) then
            return v
        end
    end
end
