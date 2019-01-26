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

function MapVote:Start(voteTime)
    if self.runs then return end

    self:Init() -- init server MapVote

    MapVote.voteTime = voteTime and voteTime or self.config.voteTime
	local mapsAndGMs = {}
	for k, mapAndGM in pairs(MapVote.maps) do
		for map, gamemode in pairs(mapAndGM) do
			mapsAndGMs[map] = gamemode
		end
	end

    net.Start("MapVote_Start")
    net.WriteUInt(MapVote.voteTime, 16)
    net.WriteTable(MapVote.maps)
    net.Broadcast()

    timer.Create("MapVoteWinnerCheck", MapVote.voteTime, 1, function()
        MapVote.active = false

        local voteResults = {}

        -- initialize 
        for k, mapAndGM in pairs(MapVote.maps) do
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
        local mapAndGM = MapVote.maps[winner]

		local mapName
		local gamemode
		for m, g in pairs(mapAndGM) do
			gamemode = g
			mapName = m
		end

        self:UpdateRevoteBanList()
        self:AddToRevoteBanList(mapName)
        self:SaveRevoteBanList()

        net.Start("MapVote_End")
        net.WriteUInt(winner, 32)
        net.Broadcast()

		timer.Simple(5, function()
            RunConsoleCommand("gamemode", gamemode)
        end)

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
    ConfigHelper:WriteConfig("revotebanlist", revoteBanListString)
end

function MapVote:InitConfig()
    local defaultConfig = {
        voteTime = 20,
        mapsToVote = 20,
        mapRevoteBanRounds = 4,
        mapPrefixes = {"ttt_"},
        mapExcludes = {},
		defaultGamemode = "terrortown"
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
    local maps = {}
	local customGMs = false

	if file.Exists("lythos_mapvote/maplist.txt",  "DATA") then
		customGMs = true
		local mlFile = file.Open("lythos_mapvote/maplist.txt", "r", "DATA") -- gotta do it this way because there's a limit the the length of a single string
		local index = 0
		local line = mlFile:ReadLine()
		while line do
			local mGmPair = string.Split(string.gsub(line, "\n", ""), ":") -- remove newline character and split maps from GMs
			local map = mGmPair[1]
			local gamemodes = mGmPair[2]

			if file.Exists("maps/"..map..".bsp", "GAME") then  -- check that the map file actually exists....
				maps[map] = gamemodes
			end

			index = index + #line
			mlFile:Seek(index)-- move to the start of the next line
			line = mlFile:ReadLine()
		end
		mlFile:Close()
	else
		local mapFiles = file.Find("maps/*.bsp", "GAME")
		for k, map in pairs(mapFiles) do
			maps[map:sub(1, -5)] = {self.config.defaultGamemode}
		end
	end

    local result = {}
    local i = 0
    local max = self.config.mapsToVote

    for map, gamemodes in RandomPairs(maps) do
        if i >= max then break end

		local mapInConfig = customGMs -- this checks that it's in the map list, or if that's not being used that it has the right prefix
		if !mapInConfig then mapInConfig = self:HasPrefix(map) end
        local notExistsInRevoteBanList = not self.revoteBanList[map]
        local notExclude = not self:IsExlude(map)

        if mapInConfig and notExistsInRevoteBanList and notExclude then 
            local mapAndGM = {}
			local gamemodesList = string.Split(gamemodes, ",")
			mapAndGM[map] = gamemodesList[math.random(#gamemodesList)] -- randomly selects one of the gamemodes linked to that map
			table.insert(result, mapAndGM)
            i = i + 1
        end
    end

	print(table.ToString(result, "Maps and GMs", true))
    return result
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
end )