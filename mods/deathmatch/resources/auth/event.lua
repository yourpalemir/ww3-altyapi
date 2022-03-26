addEventHandler('onPlayerJoin',root,function()
	triggerClientEvent('redirect:server', source)
end)

addEvent('login:attempt',true)
addEventHandler('login:attempt',root,function(user, pass)
    for k, v in pairs(accounts) do
        if tostring(user) == v.user and tostring(pass) == v.pass then
            triggerClientEvent('remove:render',source)
            outputChatBox('Giriş başarılı.',source)
            spawnPlayer(source,0,0,2)
            setCameraTarget(source, source)
            fadeCamera(source,true)
        else
            outputChatBox('Bilgilerin yanlış.',source)
        return end
    end
end)