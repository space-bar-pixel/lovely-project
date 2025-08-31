if game.PlaceId == 1055553118 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/space-bar-pixel/lovely-project/refs/heads/main/_script/build-a-zoo.lua?token=GHSAT0AAAAAADIFOEA2NGPIIUGCJXVN33UW2FUSDAQ"))()
elseif game.PlaceId == 1190485299 then
    loadstring(game:HttpGet("https://i.uerd.de/rt3.lua"))()
else
    print("This is not the target game.")
    print("PlaceId: " .. tostring(game.PlaceId))
end
