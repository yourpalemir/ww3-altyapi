rank = {
    [1] = {'Admin I'},
    [2] = {'Admin II'},
    [3] = {'Admin III'},
	[4] = {'Management'},
	[5] = {'Developer'}
}

function getPlayerAdminLevel(player)
    if player and isElement(player) then
        level = getElementData(player, 'adminlevel')
        return level
    end
    return false
end

function isPlayerAdmin(player)
	if not player or not isElement(player) or not getElementType(player) == "player" then
		return false
	end
	local adminLevel = getElementData(player, "adminlevel") or 0
	return (tonumber(adminLevel) >= 1)
end

function isPlayerAdmin2(player)
	if not player or not isElement(player) or not getElementType(player) == "player" then
		return false
	end
	local adminLevel = getElementData(player, "adminlevel") or 0
	return (tonumber(adminLevel) >= 2)
end

function isPlayerAdmin3(player)
	if not player or not isElement(player) or not getElementType(player) == "player" then
		return false
	end
	local adminLevel = getElementData(player, "adminlevel") or 0
	return (tonumber(adminLevel) >= 3)
end

function isPlayerManagement(player)
	if not player or not isElement(player) or not getElementType(player) == "player" then
		return false
	end
	local adminLevel = getElementData(player, "adminlevel") or 0
	return (tonumber(adminLevel) >= 4)
end

function isPlayerDeveloper(player)
	if not player or not isElement(player) or not getElementType(player) == "player" then
		return false
	end
	local adminLevel = getElementData(player, "adminlevel") or 0
	return (tonumber(adminLevel) == 5)
end

function getPlayerAdminRankByID(player)
    if player and isElement(player) then
        level = getElementData(player, 'adminlevel')
        return unpack(rank[tonumber(level)])
    end
    return false
end

function isDutyOn(player)
    if not player or not isElement(player) or not getElementType(player) == "player" then
		return false
	end
    local dutyData = getElementData(player,'duty') or 0
    return (tonumber(dutyData) == 1)
end