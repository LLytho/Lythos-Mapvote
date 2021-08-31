ConfigHelper = {}

function ConfigHelper:CreateConfigFolderIfNotExists()
    if not file.Exists("lythos_mapvote", "DATA") then
        file.CreateDir("lythos_mapvote")
    end
end

function ConfigHelper:ReadConfig(configFile) 
    local jsonString = file.Read("lythos_mapvote/" .. configFile .. ".txt", "DATA")
    local json = util.JSONToTable(jsonString)

    if json == nil then
        print("Reading json config failed. Make sure you have the correct json format. You can use an online json validator to check errors");
    end

    return json
end

function ConfigHelper:WriteConfig(configFile, config) 
    local configString = util.TableToJSON(config, true) -- true = prettyPrint
    file.Write("lythos_mapvote/" .. configFile .. ".txt", configString)
end