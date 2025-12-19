local Util = {}

function Util.CreateRadiusBlip(Data)
    local Blip = AddBlipForRadius(Data.Coords.x, Data.Coords.y, Data.Coords.z, Data.Radius)
    SetBlipHighDetail(Blip, true)
    SetBlipColour(Blip, Data.Color)
    SetBlipAlpha (Blip, 128)

    return Blip
end

function Util.CreateBlip(Data)
    local Blip = AddBlipForCoord(Data.Coords.x, Data.Coords.y, Data.Coords.z)
    SetBlipSprite(Blip, Data.Sprite)
    SetBlipDisplay(Blip, 4)
    SetBlipScale(Blip, Data.Scale)
    SetBlipColour(Blip, Data.Color)
    SetBlipAsShortRange(Blip, true)

    return Blip
end

return Util