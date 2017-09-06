ConfigHelper = {}

function ConfigHelper:CreateConfigFolderIfNotExists()
    if not file.Exists("lythos_mapvote", "DATA") then
        file.CreateDir("lythos_mapvote")
    end
end

function ConfigHelper:ReadConfig(configFile) 
    local jsonString = file.Read("lythos_mapvote/" .. configFile .. ".txt", "DATA")
    return util.JSONToTable(jsonString)
end

function ConfigHelper:WriteConfig(configFile, config) 
    local configString = util.TableToJSON(config, true) -- true = prettyPrint
    file.Write("lythos_mapvote/" .. configFile .. ".txt", configString)
end