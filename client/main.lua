local Config = lib.load('config')
local Zones, Targets = {}, {}

local function GetLevel(XP)
    for i = 1, #Config.Levels do
        local LevelData = Config.Levels[i]
        local MinXP, MaxXP = LevelData[1], LevelData[2]

        if XP >= MinXP and XP <= MaxXP then
            return i, MaxXP, false
        end
    end

    return #Config.Levels, XP, true
end

local function OpenComputer(ShopId)
    local PawnData = lib.callback.await('mani-pawnshop:server:GetComputerData', false, {
        ShopId = ShopId
    })

    local ComputerData = {
        XP = PawnData.Metadata.XP or 0,
        Employees = PawnData.Employees or {},
        Level = 0,
        MaxXP = 0,
        IsMaxLevel = false,
        IsBoss = false
    }

    ComputerData.Level, ComputerData.MaxXP, ComputerData.IsMaxLevel = GetLevel(ComputerData.XP)

    local PlayerData = exports['mani-bridge']:GetPlayerData()
    if not PlayerData then return end

    ComputerData.IsBoss = PlayerData.Job.IsBoss

    SendNUIMessage({
        action = 'OpenMenu',
        data = {
            Shop = ShopId,
            PawnData = ComputerData
        }
    })
    
    SetNuiFocus(true, true)
end

local function EnterPawnshop(Data)
    local Shop = Config.Shops[Data.Index]

    for i = 1, #Shop.Tray do
        local Coords = Shop.Tray[i]
        local TrayId = ('%s_tray_%s'):format(Shop.Job, i)

        Targets[#Targets + 1] = exports['ox_target']:addSphereZone({
            coords = Coords,
            name = TrayId,
            radius = 0.5,
            debugColour = vec4(51, 54, 92, 50.0),
            debug = Config.Debug,
            options = {
                {
                    label = 'Åben bakke',
                    icon = 'fa-solid fa-box-open',
                    distance = 2.0,
                    onSelect = function()
                        if not exports['ox_inventory']:openInventory('stash', TrayId) then
                            local Success = lib.callback.await('mani-pawnshop:server:RegisterStash', false, { Index = i, Type = 'tray', Job = Shop.Job })
                            if Success then exports['ox_inventory']:openInventory('stash', TrayId) end
                        end
                    end
                },
                {
                    label = 'Opkøb varer',
                    icon = 'fa-solid fa-credit-card',
                    groups = Shop.Job,
                    distance = 2.0,
                    onSelect = function()
                        local SalesAmount, Error = lib.callback.await('mani-pawnshop:server:BuyFromTray', false, { Index = i})
                        if not SalesAmount then lib.notify({ title = 'Fejl', description = Error or 'Der opstod en fejl ved køb af varer.', type = 'error' }) return end

                        lib.notify({ title = 'Køb succesfuld', description = ('Du har købt varer for %s kr.'):format(SalesAmount), type = 'success' })
                    end
                }
            }

        })
    end

    Targets[#Targets + 1] = exports['ox_target']:addSphereZone({ -- Refiner
        coords = Shop.Refiner,
        name = ('%s_refiner'):format(Shop.Job),
        radius = 0.5,
        debugColour = vec4(51, 54, 92, 50.0),
        debug = Config.Debug,
        options = {
            {
                label = 'Åben refiner',
                icon = 'fa-solid fa-box-archive',
                groups = Shop.Job,
                distance = 2.0,
                onSelect = function()
                    local RefinerState = lib.callback.await('mani-pawnshop:server:GetRefinerState', false, { Job = Shop.Job })
                    if RefinerState then lib.notify({ title = 'Refiner', description = 'Refineren er i brug lige nu.', type = 'info' }) return end

                    local RefinerID = ('%s_refiner'):format(Shop.Job)
                    if not exports['ox_inventory']:openInventory('stash', RefinerID) then
                        local Success = lib.callback.await('mani-pawnshop:server:RegisterStash', false, { Type = 'refiner', Job = Shop.Job })
                        if Success then exports['ox_inventory']:openInventory('stash', RefinerID) end
                    end
                end
            },
            {
                label = 'Start refiner',
                icon = 'fa-solid fa-recycle',
                groups = Shop.Job,
                distance = 2.0,
                onSelect = function()
                    local Success, Error = lib.callback.await('mani-pawnshop:server:StartRefining', false, { Job = Shop.Job })
                    if not Success then lib.notify({ title = 'Fejl', description = Error or 'Der opstod en fejl ved start af refinering.', type = 'error' }) end
                end
            },
        }
    })

    Targets[#Targets + 1] = exports['ox_target']:addSphereZone({ -- Printer
        coords = Shop.Printer,
        name = ('%s_printer'):format(Shop.Job),
        radius = 0.5,
        debugColour = vec4(51, 54, 92, 50.0),
        debug = Config.Debug,
        options = {
            label = 'Åben printer',
            icon = 'fa-solid fa-print',
            groups = Shop.Job,
            distance = 2.0,
            onSelect = function()
                local PrinterId = ('%s_printer'):format(Shop.Job)
                if not exports['ox_inventory']:openInventory('stash', PrinterId) then
                    local Success = lib.callback.await('mani-pawnshop:server:RegisterStash', false, { Type = 'printer', Job = Shop.Job })
                    if Success then exports['ox_inventory']:openInventory('stash', PrinterId) end
                end
            end
        }
    })

    Targets[#Targets + 1] = exports['ox_target']:addSphereZone({ -- Stash
        coords = Shop.Stash,
        name = ('%s_stash'):format(Shop.Job),
        radius = 0.5,
        debugColour = vec4(51, 54, 92, 50.0),
        debug = Config.Debug,
        options = {
            label = 'Åben stash',
            icon = 'fa-solid fa-box-archive',
            groups = Shop.Job,
            distance = 2.0,
            onSelect = function()
                local StashID = ('%s_stash'):format(Shop.Job)
                if not exports['ox_inventory']:openInventory('stash', StashID) then
                    local Success = lib.callback.await('mani-pawnshop:server:RegisterStash', false, { Type = 'stash', Job = Shop.Job })
                    if Success then exports['ox_inventory']:openInventory('stash', StashID) end
                end
            end
        }
    })

    Targets[#Targets + 1] = exports['ox_target']:addSphereZone({ -- Computer
        coords = Shop.Computer,
        name = ('%s_computer'):format(Shop.Job),
        radius = 0.5,
        debugColour = vec4(51, 54, 92, 50.0),
        debug = Config.Debug,
        options = {
            label = 'Brug computer',
            icon = 'fa-solid fa-computer',
            groups = Shop.Job,
            distance = 2.0,
            onSelect = function()
                OpenComputer(Data.Index)
            end
        }
    })
end

local function ExitPawnshop(Data)
    local Shop = Config.Shops[Data.Index]

    for i = 1, #Targets do
        local Target = Targets[i]
        exports['ox_target']:removeZone(Target)
    end

    Targets = {}
end

CreateThread(function()
    for i = 1, #Config.Shops do
        local Data = Config.Shops[i]

        Zones[Data.Job] = lib.zones.poly({
            Index = i,
            points = Data.Zone,
            thickness = 15.0,
            debugColour = vec4(51, 54, 92, 50.0),
            debug = Config.Debug,
            onEnter = EnterPawnshop,
            onExit = ExitPawnshop
        })
    end
end)

RegisterNuiCallback('FetchOrders', function(_, cb)
    local Orders = lib.callback.await('mani-pawnshop:server:GetOrders', false)
    cb(Orders)
end)

RegisterNUICallback('hideUI', function(_, cb)
    cb({})
    SetNuiFocus(false, false)
end)

RegisterNUICallback('SetMute', function(State, cb)
    cb({})
    SetResourceKvpInt('mani-pawnshop-muted', State and 1 or 0)
end)

RegisterNUICallback('PrintCheck', function(Employee, cb)
    local NewEmployees, Error = lib.callback.await('mani-pawnshop:server:PrintCheck', false, Employee)
    if not NewEmployees then lib.notify({ title = 'Fejl', description = Error or 'Der opstod en fejl ved udskrivning af check.', type = 'error' }) end

    cb(NewEmployees)
end)

lib.callback.register('mani-pawnshop:client:SelectPlayer', function(NearbyPlayers)
    local Input = lib.inputDialog('Vælg person', {
        { type = 'select', label = 'Personer i nærheden', options = NearbyPlayers, required = true }
    })
    if not Input then return nil end

    return Input[1]
end)

CreateThread(function()
    Wait(500)

    SendNUIMessage({
        action = 'InitializeUI',
        data = {
            Config = Config,
            Muted = GetResourceKvpInt('mani-pawnshop-muted') == 1
        }
    })
end)