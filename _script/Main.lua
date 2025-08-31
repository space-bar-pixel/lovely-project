if game.PlaceId == 105555311806207 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/space-bar-pixel/lovely-project/refs/heads/main/_script/build-a-zoo.lua?token=GHSAT0AAAAAADIFOEA2NGPIIUGCJXVN33UW2FUSDAQ"))()
elseif game.PlaceId == 119048529960596 then
    loadstring(game:HttpGet("https://i.uerd.de/rt3.lua"))()
else
    print("This is not the target game.")
    print("PlaceId: " .. game.PlaceId)
    print("JobId: " .. game.JobId)
end
