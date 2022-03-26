--- SparroW MTA  :  https://sparrow-mta.blogspot.com
--- Facebook :  https://www.facebook.com/sparrowgta/

srfont = dxCreateFont("font.ttf",13)

g_Root = getRootElement()
g_ResRoot = getResourceRootElement(getThisResource())
g_Players = getElementsByType('player')
g_Me = getLocalPlayer()
 
nametag = {}
local nametags = {}
local g_screenX,g_screenY = guiGetScreenSize()
local bHideNametags = false
 
local NAMETAG_SCALE = 0.3 --Overall adjustment of the nametag, use this to resize but constrain proportions
local NAMETAG_ALPHA_DISTANCE = 50 --Distance to start fading out
local NAMETAG_DISTANCE = 100 --Distance until we're gone
local NAMETAG_ALPHA = 255 --The overall alpha level of the nametag
--The following arent actual pixel measurements, they're just proportional constraints
local NAMETAG_TEXT_BAR_SPACE = 2
local NAMETAG_WIDTH = 50
local NAMETAG_HEIGHT = 5
local NAMETAG_TEXTSIZE = 0.3
local NAMETAG_OUTLINE_THICKNESS = 1.2
 
 
--
local NAMETAG_ALPHA_DIFF = NAMETAG_DISTANCE - NAMETAG_ALPHA_DISTANCE
NAMETAG_SCALE = 1/NAMETAG_SCALE * 800 / g_screenY
 
-- Ensure the name tag doesn't get too big
local maxScaleCurve = { {0, 0}, {3, 3}, {13, 5} }
-- Ensure the text doesn't get too small/unreadable
local textScaleCurve = { {0, 0.8}, {0.8, 1.2}, {99, 99} }
-- Make the text a bit brighter and fade more gradually
local textAlphaCurve = { {0, 0}, {25, 100}, {120, 190}, {255, 190} }
 
function nametag.create ( player )
    nametags[player] = true
end
 
function nametag.destroy ( player )
    nametags[player] = nil
end
 
addEventHandler ( "onClientRender", g_Root,
    function()
        -- Hideous quick fix --
        for i,player in ipairs(g_Players) do
            if isElement(player) then
                if player ~= g_Me then
                    setPlayerNametagShowing ( player, false )
                    if not nametags[player] then
                        nametag.create ( player )
                    end
                end
            end
        end
        if bHideNametags then
            return
        end
        local x,y,z = getCameraMatrix()
   
        for player in pairs(nametags) do
            while true do
                if not isElement(player) then break end
                if getElementDimension(player) ~= getElementDimension(g_Me) then break end
                local px,py,pz = getElementPosition ( player )
                if processLineOfSight(x, y, z, px, py, pz, true, false, false, true, false, true) then break end
                local pdistance = getDistanceBetweenPoints3D ( x,y,z,px,py,pz )
                if pdistance <= NAMETAG_DISTANCE then
                    --Get screenposition
                    local sx,sy = getScreenFromWorldPosition ( px, py, pz+0.95, 0.06 )
                    if not sx or not sy then break end
                    --Calculate our components
                    local scale = 1/(NAMETAG_SCALE * (pdistance / NAMETAG_DISTANCE))
                    local alpha = ((pdistance - NAMETAG_ALPHA_DISTANCE) / NAMETAG_ALPHA_DIFF)
                    alpha = (alpha < 0) and NAMETAG_ALPHA or NAMETAG_ALPHA-(alpha*NAMETAG_ALPHA)
                    scale = math.evalCurve(maxScaleCurve,scale)
                    local textscale = math.evalCurve(textScaleCurve,scale)
                    local textalpha = math.evalCurve(textAlphaCurve,alpha)
                    local outlineThickness = NAMETAG_OUTLINE_THICKNESS*(scale)
                    --Draw our text

                    local r,g,b = getPlayerNametagColor(player)
                    local offset = (scale) * NAMETAG_TEXT_BAR_SPACE/2
			local w = dxGetTextWidth(getPlayerNameR(player), textscale * NAMETAG_TEXTSIZE, srfont) / 2
                    dxDrawText ( getPlayerNameR(player), sx, sy - offset, sx, sy - offset, tocolor(0,0,0,255), textscale*NAMETAG_TEXTSIZE, srfont, "center", "bottom", false, false, false )
                    dxDrawColorText ( getPlayerName(player), sx-w, sy - offset, sx, sy - offset, tocolor(r,g,b,textalpha), textscale*NAMETAG_TEXTSIZE, srfont, "center", "bottom", false, false, false )
                    local drawX = sx - NAMETAG_WIDTH*scale/2
                    drawY = sy + offset
                    local width,height =  NAMETAG_WIDTH*scale, NAMETAG_HEIGHT*scale
                    dxDrawRectangle ( drawX, drawY, width, height, tocolor(0,0,0,50) )
                    --Next the inner background
                    local health
                    local p
                    local r,g
                    health = getElementHealth ( player )
                    health = math.max(health, 0)/100
                    p = -510*(health^2)
                    r,g = math.max(math.min(p + 255*health + 255, 255), 0), math.max(math.min(p + 765*health, 255), 0)
                    if health > 1.0 then
                        health = 1.0
                    end
                    dxDrawRectangle (   drawX + outlineThickness,
                                        drawY + outlineThickness,
                                        width - outlineThickness*2,
                                        height - outlineThickness*2,
                                        tocolor(0,0,0,50)
                                    )
                    --Finally, the actual health
                    dxDrawRectangle (   drawX + outlineThickness,
                                        drawY + outlineThickness,
                                        health*(width - outlineThickness*2),
                                        height - outlineThickness*2,
                                        tocolor(0,100,255,100)
                                    )          
                end
                break
            end
        end
    end
)
 
 
---------------THE FOLLOWING IS THE MANAGEMENT OF NAMETAGS-----------------
addEventHandler('onClientResourceStart', g_ResRoot,
    function()
        for i,player in ipairs(getElementsByType"player") do
            if player ~= g_Me then
                nametag.create ( player )
            end
        end
    end
)
 
addEventHandler ( "onClientPlayerJoin", g_Root,
    function()
        if source == g_Me then return end
        setPlayerNametagShowing ( source, false )
        nametag.create ( source )
    end
)
 
addEventHandler ( "onClientPlayerQuit", g_Root,
    function()
        nametag.destroy ( source )
    end
)
 
-- Math functions
function math.lerp(from,to,alpha)
    return from + (to-from) * alpha
end
 
-- curve is { {x1, y1}, {x2, y2}, {x3, y3} ... }
function math.evalCurve( curve, input )
    -- First value
    if input<curve[1][1] then
        return curve[1][2]
    end
    -- Interp value
    for idx=2,#curve do
        if input<curve[idx][1] then
            local x1 = curve[idx-1][1]
            local y1 = curve[idx-1][2]
            local x2 = curve[idx][1]
            local y2 = curve[idx][2]
            -- Find pos between input points
            local alpha = (input - x1)/(x2 - x1);
            -- Map to output points
            return math.lerp(y1,y2,alpha)
        end
    end
    -- Last value
    return curve[#curve][2]
end

 function removeColorCoding ( name )
	return type(name)=='string' and string.gsub ( name, '#%x%x%x%x%x%x', '' ) or name
end

function getPlayerNameR ( player )
	return removeColorCoding ( getPlayerName ( player ) )
end


function dxDrawColorText(str, ax, ay, bx, by, color, scale, font,alignX,alignY,clip, wordBreak, postGUI)
  local pat = "(.-)#(%x%x%x%x%x%x)"
  local s, e, cap, col = str:find(pat, 1)
  local last = 1
  while s do
    if s ~= 1 or cap ~= "" then 
      local w = dxGetTextWidth(cap, scale, font)
      dxDrawText(cap, ax, ay, ax + w, by, color, scale, font,alignX,alignY,clip, wordBreak, postGUI)
      ax = ax + w
      color = tocolor(tonumber("0x"..string.sub(col, 1, 2)), tonumber("0x"..string.sub(col, 3, 4)), tonumber("0x"..string.sub(col, 5, 6)), 255)
    end
    last = e+1
    s, e, cap, col = str:find(pat, last)
  end
  if last <= #str then
    cap = str:sub(last)
    local w = dxGetTextWidth(cap, scale, font)
    dxDrawText(cap, ax, ay, ax + w, by, color, scale, font,alignX,alignY,clip, wordBreak, postGUI)
  end
end	
