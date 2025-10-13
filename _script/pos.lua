local mountain = {}
local id = 1

for v = 0, 5 do
    for h = 0, 17 do
        table.insert(mountain, {
            id = tostring(id),
            coord = string.format("%d, 16, %d", -44 + -8*h, 204 + 8*v),
            empty = true
        })
        id = id + 1
    end
end

for v = 0, 5 do
    for h = 0, 13 do
        table.insert(mountain, {
            id = tostring(id),
            coord = string.format("%d, 16, %d", -60 + -8*h, 252 + 8*v),
            empty = true
        })
        id = id + 1
    end
end

for _, m in ipairs(mountain) do
    print(string.format('{id="%s", coord="%s", empty=%s},', m.id, m.coord, tostring(m.empty)))
end
