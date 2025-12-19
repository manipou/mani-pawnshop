local Util = {}

Util.CreateRadiusBlip = function(Data)
    local Blip = AddBlipForRadius(Data.Coords.xyz, Data.Radius)
    SetBlipHighDetail(Blip, true)
    SetBlipColour(Blip, Data.Color)
    SetBlipAlpha (Blip, 128)

    return Blip
end

return Util