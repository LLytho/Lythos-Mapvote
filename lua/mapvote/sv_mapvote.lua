util.AddNetworkString("MapVote_Start")
util.AddNetworkString("MapVote_Stop")
util.AddNetworkString("MapVote_End")
util.AddNetworkString("MapVote_UpdateFromClient")
util.AddNetworkString("MapVote_UpdateToAllClient")

net.Receive("MapVote_UpdateFromClient", function(len, ply)
    if MapVote.active then
        local id = net.ReadUInt(32)
        net.Start("MapVote_UpdateToAllClient")
        net.WriteEntity(ply)
        net.WriteUInt(id, 32)
        net.Broadcast()

        MapVote.votes[ply:UniqueID()] = id
    end
end)

function MapVote:GetVoteTime(baseVoteTime)
    if NO_MAPICON_DEBUG then 
        return 0
    end

    return baseVoteTime and baseVoteTime or self.config.voteTime
end
function MapVote:Start(voteTime)
    if self.runs then return end

    self:Init() -- init server MapVote

    MapVote.voteTime = self:GetVoteTime(voteTime)

    net.Start("MapVote_Start")
    net.WriteUInt(MapVote.voteTime, 16)
    net.WriteTable(MapVote.maps)
    net.Broadcast()

    timer.Create("MapVoteWinnerCheck", MapVote.voteTime, 1, function()
        MapVote.active = false

        local voteResults = {}

        -- initialize 
        for k, map in pairs(MapVote.maps) do
            voteResults[k] = 0 
        end

        for plyId, votedButton in pairs(MapVote.votes) do
            voteResults[votedButton] = voteResults[votedButton] + 1
        end

        local winnerKey = table.GetWinningKey(voteResults)
        local winnerValue = voteResults[winnerKey]

        -- search for all winner votes
        local winners = {}
        local max = 0
        for k, v in pairs(voteResults) do
            if v > max then
                max = v
                winners = {}
            end

            if v == max then
                table.insert(winners, k)
            end
        end

        local winner = table.Random(winners)
        local mapName = MapVote.maps[winner]

        self:UpdateRevoteBanList()
        self:AddToRevoteBanList(mapName)
        self:SaveRevoteBanList()

        net.Start("MapVote_End")
        net.WriteUInt(winner, 32)
        net.Broadcast()

        timer.Simple(5, function()
            RunConsoleCommand("changelevel", mapName)
        end)
    end)
end

function MapVote:Stop()
    if not self.runs then return end

    net.Start("MapVote_Stop")
    net.Broadcast()
    timer.Stop("MapVoteWinnerCheck")
    PrintMessage(HUD_PRINTTALK, "The mapvote was cancled by an admin")
    self.runs = false
end


function MapVote:LoadRevoteBanList() 
    ConfigHelper:CreateConfigFolderIfNotExists()

    if file.Exists("lythos_mapvote/revotebanlist.txt", "DATA") then
        self.revoteBanList = ConfigHelper:ReadConfig("revotebanlist")
    end

    if not self.revoteBanList then
        self.revoteBanList = {}
    end
end

function MapVote:AddToRevoteBanList(mapname)
    if not self.revoteBanList then return end
    if not self.config then return end
    if self.config.mapRevoteBanRounds <= 0 then return end

    self.revoteBanList[mapname] = self.config.mapRevoteBanRounds
end

function MapVote:UpdateRevoteBanList()
    if not self.revoteBanList then return end
    if NO_MAPICON_DEBUG then return end

    for k, v in pairs(self.revoteBanList) do
        self.revoteBanList[k] = v - 1
        if self.revoteBanList[k] == 0 then
            self.revoteBanList[k] = nil
        end
    end
end

function MapVote:SaveRevoteBanList()
    if not self.revoteBanList then return end

    ConfigHelper:CreateConfigFolderIfNotExists()
    ConfigHelper:WriteConfig("revotebanlist", self.revoteBanList)
end

function MapVote:InitConfig()
    local defaultConfig = {
        voteTime = 20,
        mapsToVote = 10,
        mapRevoteBanRounds = 4,
        mapPrefixes = {"ttt_"},
        mapExcludes = {}
    }
    self.config = defaultConfig

    ConfigHelper:CreateConfigFolderIfNotExists()

    if file.Exists("lythos_mapvote/config.txt", "DATA") then
        self.config = ConfigHelper:ReadConfig("config")

        if not self:ConfigIsValid() then
            self.config = defaultConfig
        end
    end

    ConfigHelper:WriteConfig("config", self.config)
end

function MapVote:ConfigIsValid()
    if not self.config then 
        return false 
    end

    return true
end

function MapVote:GetRandomMaps()
    local maps = file.Find("maps/*.bsp", "GAME")
    maps = self:RemoveFileExtensions(maps)
    maps = self:FilterMissingIconMaps(maps)

    local result = {}

    local i = 0
    local max = self.config.mapsToVote

    for k, map in RandomPairs(maps) do
        if i >= max then break end   

        local notExistsInRevoteBanList = not self.revoteBanList[map]
        local notExclude = not self:IsExlude(map)

        if self:HasPrefix(map) and notExistsInRevoteBanList and notExclude then
            if not a and not b then  
                table.insert(result, map)
                i = i + 1
            end
        end
    end

    return result
end

function MapVote:RemoveFileExtensions(maps) 
    local result = {}
    for k, map in RandomPairs(maps) do
        table.insert(result, map:sub(1, -5))
    end
    return result
end

function MapVote:FilterMissingIconMaps(maps) 
    if not NO_MAPICON_DEBUG then
        return maps;
    end

    local result = {}
    for k, map in RandomPairs(maps) do
        if(self:HasNoIcon(map)) then
            table.insert(result, map)
        end
    end
    return result
end

function MapVote:HasNoIcon(map)
    return not file.Exists("maps/thumb/" .. map .. ".png", "GAME") and not file.Exists("maps/" .. map .. ".png", "GAME")
end

function MapVote:HasPrefix(map)
    local prefixes = self.config.mapPrefixes
    if table.Count(prefixes) == 0 then
        return true
    end

    for k, prefix in pairs(prefixes) do
        if string.StartWith(map, prefix) then
            return true
        end
    end

    return false
end

function MapVote:IsExlude(map)
    local excludes = self.config.mapExcludes
    if table.Count(excludes) == 0 then
        return false
    end

    for k, exclude in pairs(excludes) do
        if map == exclude then
            return true
        end
    end

    return false
end

hook.Add("Initialize", "Initialize mapvote config", function()
    MapVote:InitConfig()
    MapVote:LoadRevoteBanList()
end )

hook.Add("Initialize", "MapChangeInitHook", function()
    if GAMEMODE_NAME == "terrortown" then
        function CheckForMapSwitch()
            local rounds_left = math.max(0, GetGlobalInt("ttt_rounds_left", 6) - 1)
            SetGlobalInt("ttt_rounds_left", rounds_left)

            local time_left = (GetConVar("ttt_time_limit_minutes"):GetInt() * 60) - 2 -- a bit delay

            if rounds_left <= 0 or time_left <= 0 then
                timer.Stop("end2prep")
                MapVote:Start()
            end
        end
    end

    if GAMEMODE_NAME == "murder" then
        GAMEMODE.ChangeMap = function()
            MapVote:Start()
        end
    end
end )