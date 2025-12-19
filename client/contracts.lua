local Config, Util = lib.load('Config'), lib.load('Util')

local Targets, Blips, BlacklistedEntities, Contract = {}, {}, {}, {}

local function MigrateNetId(NetId)
    while not NetworkDoesEntityExistWithNetworkId(NetId) do Wait(100) end

    SetNetworkIdCanMigrate(NetId, true)
    SetNetworkIdExistsOnAllMachines(NetId, true)
end

local function ClearContract()
    for i = 1, #Blips do
        RemoveBlip(Blips[i])
    end

    Blips = {}

    Contract = {}

    LocalPlayer.state.ManiBusy = false
end

local function DumpsterDive()
    local DConfig = Config.Contracts['DumpsterDive']
    local ZoneIndex = math.random(1, #DConfig.Zones)
    local Zone = DConfig.Zones[ZoneIndex]

    lib.notify({ title = 'Kontrakt startet', description = 'Område markeret på mappet', type = 'success' })

    Contract = lib.callback.await('mani-pawnshop:server:StartDumpsterContract', false, {
        Zone = ZoneIndex,
    })

    Blips[#Blips + 1] = Util.CreateRadiusBlip({
        Coords = Zone.Coords,
        Radius = Zone.Radius,
        Color = 2
    })

    exports['ox_target']:addModel(DConfig.DumpsterProps, {
        label = 'Led efter materialer',
        icon = 'fas fa-recycle',
        distance = 2.5,
        name = 'pawnshopDumpsters',
        canInteract = function(Entity)
            if BlacklistedEntities[Entity] then return false end

            local PlayerPed = cache.ped
            local PlayerCoords = GetEntityCoords(PlayerPed)
            PlayerCoords = vector3(PlayerCoords.x, PlayerCoords.y, 0.0)
            local ZoneCoords = Zone.Coords
            local ZoneRadius = Zone.Radius
            local DistanceToZone = #(PlayerCoords - ZoneCoords)

            return DistanceToZone <= ZoneRadius
        end,
        onSelect = function(Data)
            local PlayerPed = cache.ped
            if IsPedInAnyVehicle(PlayerPed, true) then return end

            if lib.progressBar({
                duration = DConfig.SearchTime,
                label = 'Undersøger skraldespand...',
                useWhileDead = false,
                canCancel = true,
                disable = {
                    car = true,
                    move = true,
                    combat = true
                },
                anim = {
                    dict = 'mini@repair',
                    clip = 'fixing_a_ped'
                },
            }) then
                if BlacklistedEntities[Data.entity] then return end

                lib.waitFor(function()
                    NetworkRegisterEntityAsNetworked(Data.entity)
                    return NetworkGetEntityIsNetworked(Data.entity)
                end)

                local NetId = NetworkGetNetworkIdFromEntity(Data.entity)
                MigrateNetId(NetId)

                local Success, Error = lib.callback.await('mani-pawnshop:server:SearchDumpster', false, {
                    NetId = NetId
                })

                if not Success then lib.notify({ title = 'Fejl', description = Error or 'Der skete en fejl.', type = 'error' }) return end

                Contract.Looted = Contract.Looted + 1

                if Contract.Looted >= Contract.Dumpsters then
                    lib.notify({ title = 'Kontrakt fuldført', description = ('Du har modtaget %s XP'):format(Contract.XP), type = 'success' })

                    ClearContract()

                    exports['ox_target']:removeModel(DConfig.DumpsterProps, 'pawnshopDumpsters')
                else
                    lib.notify({ title = 'Succes', description = 'Du har fundet noget materiale.', type = 'success' })
                end

                BlacklistedEntities[Data.entity] = true
            end
        end
    })
end

local Contracts = {
    DumpsterDive
}

RegisterNUICallback('StartContract', function(ContractData, cb)
    cb({})
    SetNuiFocus(false, false)

    if LocalPlayer.state.ManiBusy then lib.notify({ title = 'Fejl', description = 'Du har travlt med noget andet.', type = 'error' }) return end

    local PlayerData = exports['mani-bridge']:GetPlayerData()
    if not PlayerData then return end

    if not Config.Jobs[PlayerData.Job.Name] then return end

    if Contracts[ContractData.Id] then Contracts[ContractData.Id]() end
end)

CreateThread(function()
    Config.Jobs = {}

    for i = 1, #Config.Shops do
        local Shop = Config.Shops[i]
        Config.Jobs[Shop.Job] = true
    end
end)