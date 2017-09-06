ConfigHelper = {}

function ConfigHelper:CreateConfigFolderIfNotExists()
    if not file.Exists("lythos_mapvote", "DATA") then
        file.CreateDir("lythos_mapvote")
    end
end

function ConfigHelper:ReadConfig(configFile) 
    local jsonString = file.Read("lythos_mapvote/" .. configFile .. ".txt", "DATA")
    PrintMessage(HUD_PRINTTALK, "READ lythos_mapvote/" .. configFile .. ".txt")
    return util.JSONToTable(jsonString)
end

function ConfigHelper:WriteConfig(configFile, config) 
    local configString = util.TableToJSON(config, true) -- true = prettyPrint
    file.Write("lythos_mapvote/" .. configFile .. ".txt", configString)
    PrintMessage(HUD_PRINTTALK, "WRITE lythos_mapvote/" .. configFile .. ".txt")
end