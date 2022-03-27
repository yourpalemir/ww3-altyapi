local db = exports.sqlite:getConnection()

addEventHandler('onPlayerJoin',root,function()
	local account_Crends = determinePlayerAccount(getPlayerSerial(source))
	triggerClientEvent('redirect:server', source, account_Crends)
end)

addEvent('login:attempt',true)
addEventHandler('login:attempt',root,function(username, password)
    for k, v in pairs(accounts) do
        if (tostring(username) == tostring(v.username) and tostring(password) == tostring(v.password)) then
            setElementData(source, 'account:username', v.username)
			setElementData(source, 'adminlevel', v.admin)
            setElementData(source, 'dbid', v.id)
			setElementData(source, 'duty', 0)
            triggerClientEvent('remove:render',source)
            outputChatBox('[!] #FFFFFFGiriş başarılı.',source,255,0,0,true)
            spawnPlayer(source,v.x,v.y,v.z)
            setCameraTarget(source, source)
            fadeCamera(source,true)
			setElementModel(source, tonumber(v.skin))
        else
            outputChatBox('[!] #FFFFFFGiriş bilgilerin yanlış.',source,255,0,0,true)
        return end
    end
end)

addEventHandler('onPlayerQuit', root, function()
	x, y, z = getElementPosition(source)
	skin = getElementModel(source)
	dbExec(db, 'UPDATE accounts SET x=?, y=?, z=?, skin=? WHERE id=? ',x ,y, z, skin,tonumber(getElementData(source,'dbid')))
	for k, v in pairs(accounts) do
		if (accounts[tonumber(getElementData(source,'dbid'))]) then 
			accounts[tonumber(getElementData(source,'dbid'))] = {id=v.id, username=v.username, password=v.password, email=v.email, phonenumber=v.phonenumber, serial=v.serial, admin=v.admin, x=v.x, y=v.y, z=v.z, skin=v.skin}
		return end
	end
end)


-- oyuncunun acc sini önceden belirleyip, dakkada bi performans öldürmemek için için


function determinePlayerAccount(serial)
	for key, value in pairs(accounts) do 
		if value.serial == serial then 
			return true
		end 
	end
end 

-- kayıt 

addEvent('register:request', true)
addEventHandler('register:request', root, function(username, password)
	local serial = getPlayerSerial(source)
	if not (isAccountExists(username, password, serial)) and not (determinePlayerAccount(serial)) then
		createAccount(username,password,serial)
        outputChatBox('[!] #FFFFFFHesabın oluşturuldu.',source,255,0,0,true)
    else
        outputChatBox('[!] #FFFFFFZaten bir hesabın var.',source,255,0,0,true)
	end 
end)

function isAccountExists(username, password, serial)
	for key, value in pairs(accounts) do 
		if value.username == username or value.password == password or value.serial == serial then return true end 
	end 
end 
-- data


addEventHandler('onResourceStart', resourceRoot, function()
	dbQuery(queryAdd, db, 'SELECT * FROM accounts')
end)

function queryAdd(queryHandle)
	results = dbPoll(queryHandle, 0)
	for key, value in pairs(results) do 
		accounts[key] = {id=value.id, username=value.username, password=value.password, email=value.email, phonenumber=value.phonenumber, serial=value.serial, admin=value.admin, x=value.x, y=value.y, z=value.z, skin=value.skin}
	end 
end

function createAccount(username, password, serial)
	local query = dbExec(db, 'INSERT INTO accounts(username, password, email, phonenumber, serial, admin, x, y, z, skin) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', username, password, "undefined", "undefined", serial, 0,1480.9736328125, -1765.8916015625, 18.795755386353, 0)
	if query == true then 
		accounts[#accounts + 1] = {id=#accounts+1, username=username, password=password, email="undefined", phonenumber="undefined", serial=serial, admin=0, x=1480.9736328125, y=-1765.8916015625, z=18.795755386353, skin=0}
	end 
	return query
end