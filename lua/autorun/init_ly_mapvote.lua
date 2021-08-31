NO_MAPICON_DEBUG = false

if SERVER then
    AddCSLuaFile()
    AddCSLuaFile("mapvote/mapvote.lua")
    AddCSLuaFile("mapvote/cl_mapButton.lua")
    AddCSLuaFile("mapvote/cl_mapFrame.lua")
    AddCSLuaFile("mapvote/cl_mapvote.lua")
    include("mapvote/sv_confighelper.lua")
    include("mapvote/mapvote.lua")
    include("mapvote/sv_mapvote.lua")
    include("mapvote/sv_rtv.lua")
else
    include("mapvote/mapvote.lua")
    include("mapvote/cl_mapButton.lua")
    include("mapvote/cl_mapFrame.lua")
    include("mapvote/cl_mapvote.lua")
end

-- I use this if I add new mapicons to print the mapname on the screen.
-- Makes easier for me :D :D

if NO_MAPICON_DEBUG and CLIENT then
    hook.Add("Initialize", "Show map label", function()
        local mapNameLabel = vgui.Create("DLabel")
        mapNameLabel:SetText(game.GetMap())
        mapNameLabel:SetContentAlignment(8)
        mapNameLabel:SetPos(0, ScrH() - 250 )
        mapNameLabel:SetSize(ScrW(), 50)
        mapNameLabel:SetFont("TimeLeftFont")
        mapNameLabel:SetTextColor( Color( 255, 255, 255, 255 ) )

    end)
end

if SERVER then
    concommand.Add("printallmaps", function()
        local maps = file.Find("maps/*.bsp", "GAME")
        PrintTable(maps)
    end)
end
