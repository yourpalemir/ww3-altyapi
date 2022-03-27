function getZoneNameEx(x, y, z)
    local zone = getZoneName(x, y, z)
    if zone == 'East Beach' then
        return 'Bayrampaşa'
    elseif zone == 'Ganton' then
        return 'Bağcılar'
    elseif zone == 'East Los Santos' then
        return 'Bayrampaşa'
    elseif zone == 'Las Colinas' then
        return 'Çatalca'
    elseif zone == 'Jefferson' then
        return 'Esenler'
    elseif zone == 'Glen Park' then
        return 'Esenler'
    elseif zone == 'Downtown Los Santos' then
        return 'Kağıthane'
    elseif zone == 'Commerce' then
        return 'Beyoğlu'
    elseif zone == 'Market' then
        return 'Mecidiyeköy'
    elseif zone == 'Temple' then
        return '4. Levent'
    elseif zone == 'Vinewood' then
        return 'Kemerburgaz'
    elseif zone == 'Richman' then
        return '4. Levent'
    elseif zone == 'Rodeo' then
        return 'Sarıyer'
    elseif zone == 'Mulholland' then
        return 'Kemerburgaz'
    elseif zone == 'Red County' then
        return 'Kemerburgaz'
    elseif zone == 'Mulholland Intersection' then
        return 'Kemerburgaz'
    elseif zone == 'Los Flores' then
        return 'Sancak Tepe'
    elseif zone == 'Willowfield' then
        return 'Zeytinburnu'
    elseif zone == 'Playa del Seville' then
        return 'Zeytinburnu'
    elseif zone == 'Ocean Docks' then
        return 'İkitelli'
    elseif zone == 'Los Santos' then
        return 'İstanbul'
    elseif zone == 'Los Santos International' then
        return 'Atatürk Havalimanı'
    elseif zone == 'Jefferson' then
        return 'Esenler'
    elseif zone == 'Verdant Bluffs' then
        return 'Rümeli Hisarı'
    elseif zone == 'Verona Beach' then
        return 'Ataköy'
    elseif zone == 'Santa Maria Beach' then
        return 'Florya'
    elseif zone == 'Marina' then
        return 'Bakırköy'
    elseif zone == 'Idlewood' then
        return 'Güngören'
    elseif zone == 'El Corona' then
        return 'Küçükçekmece'
    elseif zone == 'Unity Station' then
        return 'Merter'
    elseif zone == 'Little Mexico' then
        return 'Taksim'
    elseif zone == 'Pershing Square' then
        return 'Taksim'
    elseif zone == 'Las Venturas' then
        return 'Edirne'
    else
        return zone
    end
end

sW, sH = guiGetScreenSize()
zoom = 1
active = true

if sW < 1920 then zoom = math.min(2, 1920/sW) end

RADAR_POS = {x = 50/zoom, y = sH - 275/zoom, w = 210/zoom, h = 210/zoom}
RADAR_CENTER_LEFT = RADAR_POS.x + RADAR_POS.w / 2
RADAR_CENTER_TOP = RADAR_POS.y + RADAR_POS.h / 2
BLIP_SIZE = {w = 20/zoom, h = 22/zoom}

-- 

Radar = {}
Radar.show = false

Radar.areaRenderTarget = dxCreateRenderTarget(RADAR_POS.w, RADAR_POS.h, true)

Radar.font = {
    [1] = exports.fonts:getFont("RobotoB", 11),
    [2] = exports.fonts:getFont("RobotoB", 11),
} 

Radar.blips = {
    ["player"] = "player",
    [0] = "none",
    [30] = "player",
    [10] = "burger",
    [6] = "ammu",
    [32] = "house",
    [63] = "spray",
    [45] = "clothing",
    [55] = "salon",
    [27] = "repair",
    [40] = "tuning",
    [43] = "gielda",
    [12] = "c",
    [35] = "przechowalnia",
    [41] = "checkpoint",
    [42] = "visualtune",
    [56] = "cpn",
    [39] = "office",
    [36] = "parwko",
    [52] = "dollar",
    [46] = "work",
    [30] = "pd",
    [22] = "samc",
    [53] = "race",
    [25] = "diamond",
    [20] = "fire",
}


Radar.render = function()
    if active then
        local pX, pY, pZ = getElementPosition(localPlayer)
        local _, _, pRZ = getElementRotation(localPlayer)
        local cX, cY, _, tX, tY = getCameraMatrix()
        local north = findRotation(cX, cY, tX, tY)
        local bNorth = 180 - north
        local _, _, cameraRotation = getElementRotation(getCamera())
        local x, y, z = getElementPosition(localPlayer)
        mapX = (pX) / 6000
        mapY = (pY) / -6000
        --if getElementInterior(localPlayer) == 0 then
            setPlayerHudComponentVisible('radar', false)
            dxSetShaderValue(Radar.shader, "gUVPosition", mapX, mapY)
            dxSetShaderValue(Radar.shader, "gUVRotAngle", math.rad(-cameraRotation))
            dxSetShaderValue(Radar.shader, "gUVScale", 0.15, 0.15)
            dxDrawImage(RADAR_POS.x, RADAR_POS.y, RADAR_POS.w, RADAR_POS.h, Radar.shader, 0, 0, 0, tocolor(255, 255, 255, 255))
            dxDrawImage(RADAR_CENTER_LEFT - BLIP_SIZE.w/2, RADAR_CENTER_TOP - BLIP_SIZE.h/2, BLIP_SIZE.w, BLIP_SIZE.h, Radar.blips["player"], north - pRZ)local x, y, z = getElementPosition(localPlayer)
        --end
    end
end

Radar.toggle = function(bool)
    Radar.show = bool
    if Radar.show then 
        addEventHandler("onClientRender", root, Radar.render)
    else
        removeEventHandler("onClientRender", root, Radar.render)
    end
end

Radar.start = function()
    Radar.show = true
    Radar.shader = dxCreateShader("fx/hud_mask.fx")

    Radar.mask = dxCreateTexture("images/mask.png", "argb", true, "clamp")
    Radar.map = dxCreateTexture("images/radar.png", "argb", true, "clamp")
    Radar.shadow = dxCreateTexture("images/shadow.png", "argb", true, "clamp")

    Radar.valid = Radar.shader and Radar.mask and Radar.map

    if Radar.valid then
        dxSetShaderValue(Radar.shader, "sPicTexture", Radar.map)
        dxSetShaderValue(Radar.shader, "sMaskTexture", Radar.mask)
    end


    for i, v in pairs(Radar.blips) do
        Radar.blips[i] = dxCreateTexture("images/blips/"..v..".png", "argb", true, "clamp")
    end

    addEventHandler("onClientRender", root, Radar.render)
end
addEventHandler("onClientResourceStart", resourceRoot, Radar.start)

function showRadar(bool)
    Radar.show = bool 
    if bool then 
        setPlayerHudComponentVisible('radar', false)
    else 
        setPlayerHudComponentVisible('radar', true)
    end
end

function getDistanceRotation(x, y, dist, angle)
    local a = math.rad(90 - angle)
    local dx = math.cos(a) * dist
    local dy = math.sin(a) * dist
    return x+dx, y+dy
end

function findRotation(x1,y1,x2,y2)
    local t = -math.deg(math.atan2(x2-x1,y2-y1))
    if t < 0 then t = t + 360 end
    return t
end

for i,v in ipairs(getElementsByType('blip')) do 
    if getBlipIcon(v) ~= 41 and getBlipIcon(v) ~= 12 then 
        if getBlipIcon(v) ~= 0 then 
            setBlipVisibleDistance(v, 450)
        else
            setBlipVisibleDistance(v, 210)
        end 
    end
end

function togRadar()
    if active then
        active = false
    else
        active = true
    end
end
addCommandHandler("togradar", togRadar)