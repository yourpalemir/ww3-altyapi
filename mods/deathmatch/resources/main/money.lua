-- bu kısımda para fonksiyonlarını yazdım, 10-15 dakikamı aldı umarım çalışıyordur hepsi :)

function paraCek(player)
    if player and isElement(player) then
        para = getElementData(player, 'money')
        return para
    end
    return false
end

function paraKontrol(player, value)
    value = tonumber(value) or 0
    if player and isElement(player) then
        para = getElementData(player, 'money')
        if para >= value then
            return true
        else
            return false
        end
    end
    return false
end

function paraVer(player, value)
    value = tonumber(value) or 0
    if player and isElement(player) then
        para = getElementData(player,'money')
        setElementData(player, 'money', para + value)
    end
    return false
end

function paraAl(player, value)
    value = tonumber(value) or 0
    if player and isElement(player) then
        para = getElementData(player, 'money')
        if (para - value) < 0 then
            setElementData(player,'money',0)
        else
            setElementData(player,'money', para - value)
        end
    end
    return false
end

function paraFormat(amount)
	local left,num,right = string.match(tostring(amount),'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end
