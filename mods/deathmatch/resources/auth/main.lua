screen = Vector2(guiGetScreenSize())
w, h = 300, 200
nx, ny = (screen.x-w)/2, (screen.y-h)/2

fonts = {
    [1] = exports.fonts:getFont('inter',16),
    [2] = exports.fonts:getFont('Roboto',10),
    [3] = exports.fonts:getFont('FontAwesome6',12),
    [4] = exports.fonts:getFont('Roboto',8)
}

buttons = {
    {char='Kullanıcı Adı'},
    {char='Şifre'}
}

buttons2 = {
    {char='Giriş Yap'},
    {char='Kayıt Ol'}
}

showing = false
function draw()
    if getKeyState('backspace') and click+200 <= getTickCount() then
        click = getTickCount()
        delete()
    end
    roundedRectangle(nx,ny,w,h,tocolor(60,60,60),10)
    if #buttons > 0 then
        for k, v in pairs(buttons) do
            if not mousePos(nx+w/6+125/10,ny + 60 - 40 + (k * 40),w-125,h-170) then
                dxDrawRectangle(nx+w/6+125/10,ny + 60 - 40 + (k * 40),w-125,h-170,tocolor(20,20,20))
            else
                if getKeyState('mouse1') and click+600 <= getTickCount() then
                    click = getTickCount()
                    if k == 1 and selectedText ~= 'user' then
                        selectedText = 'user'
                    elseif k == 2 and selectedText ~= 'pass' then
                        selectedText = 'pass'
                    end
                end
                dxDrawRectangle(nx+w/6+125/10,ny + 60 - 40 + (k * 40),w-125,h-170,tocolor(35,35,35))
            end
        end
    end
    if selectedText == nil then
        dxDrawText('Kullanıcı Adı',nx+w/6+125/8, ny + 65 - 40 + (1 * 40) ,w,h,tocolor(255,255,255,255),1,fonts[2])
        dxDrawText('Şifre',nx+w/6+125/8, ny + 65 - 40 + (2 * 40) ,w,h,tocolor(255,255,255,255),1,fonts[2])
    elseif selectedText == 'user' then
        if #passText > 0 then
            dxDrawText(userText,nx+w/6+125/8, ny + 65 - 40 + (1 * 40),w,h,tocolor(255,255,255,255),1,fonts[2])
            dxDrawText(string.gsub(passText,".","*"),nx+w/6+125/8, ny + 65 - 40 + (2 * 40) ,w,h,tocolor(255,255,255,255),1,fonts[2])
        else
            dxDrawText(userText,nx+w/6+125/8, ny + 65 - 40 + (1 * 40),w,h,tocolor(255,255,255,255),1,fonts[2])
            dxDrawText('Şifre',nx+w/6+125/8, ny + 65 - 40 + (2 * 40) ,w,h,tocolor(255,255,255,255),1,fonts[2])
        end
    elseif selectedText == 'pass' then
        if #userText > 0 then
            dxDrawText(userText,nx+w/6+125/8, ny + 65 - 40 + (1 * 40),w,h,tocolor(255,255,255,255),1,fonts[2])
            dxDrawText(string.gsub(passText,".","*"),nx+w/6+125/8, ny + 65 - 40 + (2 * 40) ,w,h,tocolor(255,255,255,255),1,fonts[2])
        else
            dxDrawText('Kullanıcı Adı',nx+w/6+125/8, ny + 65 - 40 + (1 * 40),w,h,tocolor(255,255,255,255),1,fonts[2])
            dxDrawText(string.gsub(passText,".","*"),nx+w/6+125/8, ny + 65 - 40 + (2 * 40) ,w,h,tocolor(255,255,255,255),1,fonts[2])
        end
    end
    if #buttons2 > 0 then
        for k, v in pairs(buttons2) do
            if not mousePos(nx+w/6+225/3.75,ny+135 - 30 + (k * 30),w-225, h-175) then
                dxDrawRectangle(nx+w/6+225/3.75,ny+135 - 30 + (k * 30),w-225, h-175, tocolor(25,25,25))
            else
                if getKeyState('mouse1') and click+600 <= getTickCount() then
                    click = getTickCount()
                    if k == 1 then
                        if #userText > 0 and #passText > 0 then 
                            triggerServerEvent('login:attempt',localPlayer, userText, passText)
                        else
                            outputChatBox('Lütfen boşlukları eksiksiz doldurun.')
                        return end
                    end
                end 
                dxDrawRectangle(nx+w/6+225/3.75,ny+135 - 30 + (k * 30),w-225, h-175, tocolor(40,40,40))
            end
            dxDrawText(v.char,nx+w/6+265/3.75,ny+140 - 30 + (k * 30),w, h,tocolor(255,255,255),1,fonts[4])
        end
    end
end
function playerJoined()
if not showing then
    setElementData(localPlayer,'isLogging',true)
    addEventHandler('onClientRender',root,draw)
    addEventHandler('onClientCharacter',root,eventWrite)
    showCursor(true)
    showing = true
    selectedText = nil
    click = 0
    userText = ''
    passText = ''
else
    setElementData(localPlayer,'isLogging',false)
    removeEventHandler('onClientRender',root,draw)
    removeEventHandler('onClientCharacter',root,eventWrite)
    showCursor(false)
    showing = false
    selectedText = nil
end
end
addEvent('redirect:server',true)
addEventHandler('redirect:server',root,playerJoined)

function eventWrite(...)
    write(...)
end

function write(character)
    if selectedText == 'user' then
        if string.len(userText) <= 12 then
            userText = ''..userText..''..character
            char = string.len(userText)+1
        end
    elseif selectedText == 'pass' then
        if string.len(passText) <= 12 then
            passText = ''..passText..''..character
            char = string.len(passText)+1
        end
    end
end

function delete()
    if selectedText == 'user' then
        if string.len(userText) > 0 then
            local firstPart = userText:sub(0, char-1)
            local lastPart = userText:sub(char+1, #userText)
            userText = firstPart..lastPart
            char = string.len(userText)
        end
    elseif selectedText == 'pass' then
        if string.len(passText) > 0 then
            local firstPart = passText:sub(0, char-1)
            local lastPart = passText:sub(char+1, #passText)
            passText = firstPart..lastPart
            char = string.len(passText)
        end
    end
end

function removeRender()
    setElementData(localPlayer,'isLogging',false)
    setElementData('isLogged', true)
    removeEventHandler('onClientRender',root,draw)
    removeEventHandler('onClientCharacter',root,eventWrite)
    showCursor(false)
    showing = false
    selectedText = nil
end
addEvent('remove:render',true)
addEventHandler('remove:render',root,removeRender)