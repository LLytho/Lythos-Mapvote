util.AddNetworkString("RTV_DoVote")

RTV = {}

RTV.rtv_votes = {}

hook.Add("PlayerSay", "RTV Chatcommand", function(ply, text, public)
	text = string.lower(text)
    text = string.Trim(text)

	if text == "!rtv" then
		ply:ConCommand("rtv")
	end
end)

concommand.Add("rtv", function(ply, cmd, args)
    if !IsValid(ply) then return end
    if not RTV:CheckRtvIsActive(ply) then return end 

    local id = ply:SteamID()

    local amount = RTV:GetNecessaryVoteAmount()
    local voteCounts = RTV:CountVotes()

    local msg = ""
    if voteCounts == 0 then
        msg = string.format("%s starts RockTheVote. (%i/%i) players need for map change.", ply:Nick(), voteCounts + 1, amount)
    else
        msg = string.format("%s joins RockTheVote. (%i/%i) players need for map change.", ply:Nick(), voteCounts, amount)   
    end

    if RTV:ExistsInTable(ply) then
        ply:ChatPrint(msg)
    else
        RTV:AddVote(ply)
        PrintMessage(HUD_PRINTTALK, "[GLOBAL] " .. msg)
    end

    RTV:StartMapvoteIfNeeded()
end)

function RTV:GetNecessaryVoteAmount()
    local playerCount = #player.GetAll()
    local percentage  = math.Clamp(self.config.percentage, 0, 1)

    local amount = math.floor(playerCount * percentage)

    return math.Clamp(amount, self.config.minVote, self.config.maxVote)
end

function RTV:ExistsInTable(ply)
    if !IsValid(ply) then return end

    for k,v in pairs(self.rtv_votes) do
        if v == ply then
            return true
        end
    end

    return false
end

function RTV:AddVote(ply) 
    if !IsValid(ply) then return end

    table.insert(RTV.rtv_votes, ply)
end

function RTV:CountVotes()
    local c = 0

    for k,ply in pairs(self.rtv_votes) do
        if IsValid(ply) then
            c = c + 1
        end
    end

    return c
end

function RTV:StartMapvoteIfNeeded()
    if self:CountVotes() >= self:GetNecessaryVoteAmount() then
        if self.config.delayUntilEnd and GetRoundState() == ROUND_ACTIVE then
            PrintMessage(HUD_PRINTTALK, "[GLOBAL] RockTheVote passed. Delaying map vote until end of round")
            hook.Add("TTTEndRound", "RTVDelay", function()
                hook.Remove("TTTEndRound", "RTVDelay")
                MapVote:Start()
            end)
        else
            MapVote:Start()
        end
    end
end

function RTV:CheckRtvIsActive(ply) 
    if CurTime() + 1 <= self.config.minPlaytimeIncCurTime then
        local time = self.config.minPlaytimeIncCurTime - CurTime()
        local seconds = time % 60
        local minutes = math.floor(time / 60)

        local msg = ""
        if minutes == 0 then
            msg = string.format("RockTheVote is allowed after %is", seconds)
        else
            msg = string.format("RockTheVote is allowed after %im%is", minutes, seconds)
        end
        
        ply:ChatPrint(msg)
        return false
    else
        return true
    end
end

function RTV:Reset()
    self.rtv_votes = {}
end

function RTV:InitConfig()
    local defaultConfig = {
        minVote = 3,
        maxVote = 7,
        percentage = 0.4,
        minPlaytime = 90,
        delayUntilEnd = true
    }
    self.config = defaultConfig

    ConfigHelper:CreateConfigFolderIfNotExists()

    if file.Exists("lythos_mapvote/rtv.txt", "DATA") then
        self.config = ConfigHelper:ReadConfig("rtv")

        if not self:ConfigIsValid() then
            self.config = defaultConfig
        end
    end

    ConfigHelper:WriteConfig("rtv", self.config)

    self.config.minPlaytimeIncCurTime = self.config.minPlaytime + CurTime()
end

function RTV:ConfigIsValid()
    if not self.config then 
        return false 
    end

    return true
end

hook.Add("Initialize", "Initialize rtv config", function()
    RTV:InitConfig()
end )