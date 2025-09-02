local scriptsByPlaceId = {
    [1055553118] = "https://raw.githubusercontent.com/space-bar-pixel/lovely-project/refs/heads/main/_script/%5Braw%5Dbuild-a-zoo.lua",
    [1190485299] = "https://raw.githubusercontent.com/space-bar-pixel/lovely-project/refs/heads/main/_script/RST3.lua"
}

local placeId = tonumber(string.sub(tostring(game.PlaceId), 1, 10))
local scriptUrl = scriptsByPlaceId[placeId]

if scriptUrl then
    print("Loading script for PlaceId:", placeId)
    --loadstring(game:HttpGet(scriptUrl))()
else
    print("No script for this PlaceId:", placeId)
end
