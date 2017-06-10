local CATEGORY_NAME = "Mapvote"

function ulx.mapvote(calling_ply, time, isOppositeCmd)
    if isOppositeCmd then MapVote:Stop() else MapVote:Start(time) end
end

local cmd = ulx.command(CATEGORY_NAME, "mapvote", ulx.mapvote, "!mapvote")
cmd:addParam{ type=ULib.cmds.NumArg, min=15, default=20, max=60, ULib.cmds.optional, hint="Votetime" } -- time param
cmd:addParam{ type=ULib.cmds.BoolArg, invisible=true } -- isOppositeCmd param
cmd:defaultAccess(ULib.ACCESS_ADMIN)
cmd:setOpposite("unmapvote", {_, _, true}, "!unmapvote")