-- this are the base mapvote stuff for client and server

MapVote = {}

function MapVote:Init()
    self.votes = {}
    self.active = true
    
    if SERVER then
        self.runs = true
        self.maps = self:GetRandomMaps()
    end
end

