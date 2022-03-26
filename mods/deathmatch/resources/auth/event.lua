addEventHandler('onPlayerJoin',root,function()
	local account_Crends = determinePlayerAccount(getPlayerSerial(source))
	triggerClientEvent('redirect:server', source, account_Crends)
end)

addEvent('login:attempt',true)
addEventHandler('login:attempt',root,function(user, pass)
    for k, v in pairs(accounts) do
        if tostring(user) == v.username and tostring(pass) == v.password then
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

-- oyuncunun acc sini önceden belirleyip, dakkada bi performans öldürmemek için için


function determinePlayerAccount(serial)
	for key, value in pairs(accounts) do 
		if value.serial == serial then 
			return value
		end 
	end 
end 

-- kayıt 

addEvent('register:request', true)
addEventHandler('register:request', root, function(username, password)
	local serial = getPlayerSerial(client)
	if isAccountExists(username, password, serial) == false then
		createAccount(username,password,serial)
        outputChatBox('Hesabın oluşturuldu.')
    else
        outputChatBox('Zaten bir hesabın var.')
	end 
end)

function isAccountExists(username, password, serial)
	for key, value in pairs(accounts) do 
		if value.username == username or value.password == password or value.serial == serial then return true end 
	end 
	return false 
end 
-- data

local db = exports.sqlite:getConnection()

addEventHandler('onResourceStart', resourceRoot, function()
	dbQuery(queryAdd, db, 'SELECT * FROM accounts')
end)

function queryAdd(queryHandle)
	results = dbPoll(queryHandle, 0)
	for key, value in pairs(results) do 
		accounts[key] = {id=value.id, username=value.username, password=value.password, email=value.email, phonenumber=value.phonenumber, serial=value.serial}
	end 
end

function createAccount(username, password, serial)
	local query = dbExec(db, 'INSERT INTO accounts(username, password, email, phonenumber, serial) VALUES(?, ?, ?, ?, ?)', username, password, "undefined", "undefined", serial)
	if query == true then 
		accounts[#accounts + 1] = {id=#accounts+1, username=username, password=password, email="undefined", phonenumber="undefined", serial=serial}
	end 
	return query
end