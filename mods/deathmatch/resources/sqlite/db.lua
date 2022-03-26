local db

addEventHandler("onResourceStart",resourceRoot,function()
    db = dbConnect("sqlite","global/sql.db")
    if db then
        outputDebugString("Database baglantisi basarili. - nox")
    end
end)

function getConnection()
    return db 
end