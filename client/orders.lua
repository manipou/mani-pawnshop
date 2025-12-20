local Config, Util = lib.load('config'), lib.load('util')

local Order = {}

local function ClearOrder()
    if Order.Blip then
        RemoveBlip(Order.Blip)
    end

    if Order.NPC then
        local Entity = Order.NPC
        exports['ox_target']:removeLocalEntity(Entity)
        SetTimeout(30000, function()
            DeleteEntity(Entity)
        end)
    end

    if Order.Point then
        Order.Point:remove()
    end

    Order = {}

    LocalPlayer.state.ManiBusy = false
end

RegisterNUICallback('AcceptOrder', function(OrderId, cb)
    cb({})
    SetNuiFocus(false, false)

    local PlayerData = exports['mani-bridge']:GetPlayerData()
    if not PlayerData then return end

    local ShopIndex = Config.Jobs[PlayerData.Job.Name]
    if not ShopIndex then return end

    if LocalPlayer.state.ManiBusy then lib.notify({ title = 'Fejl', description = 'Du har travlt med noget andet.', type = 'error' }) return end

    local Success, Error = lib.callback.await('mani-pawnshop:server:AcceptOrder', false, { OrderId = OrderId })
    if not Success then lib.notify({ title = 'Fejl', description = Error or 'Der skete en fejl.', type = 'error' }) return end
    lib.notify({ title = 'Succes', description = 'Du har accepteret ordren.', type = 'success' })

    Order = Success

    LocalPlayer.state.ManiBusy = true

    Order.Blip = Util.CreateBlip({
        Coords = Order.Coords,
        Sprite = 480,
        Scale = 0.8,
        Color = 2
    })

    SetBlipRoute(Order.Blip, true)

    Order.Point = lib.points.new({
        coords = Order.Coords,
        distance = 100.0,
        onEnter = function(self)
            local NPCMOdel = GetHashKey('s_m_y_ammucity_01')
            lib.requestModel(NPCMOdel)
            Order.NPC = CreatePed(26, NPCMOdel, Order.Coords.x, Order.Coords.y, Order.Coords.z, Order.Coords.w, false, false)
            FreezeEntityPosition(Order.NPC, true)
            SetEntityInvincible(Order.NPC, true)
            SetBlockingOfNonTemporaryEvents(Order.NPC, true)

            exports['ox_target']:addLocalEntity(Order.NPC, {
                {
                    label = 'Giv ordre',
                    icon = 'fas fa-truck-ramp-box',
                    distance = 2.0,
                    onSelect = function()
                        Order.Stash = Order.Stash or lib.callback.await('mani-pawnshop:server:RegisterTempStash', false, Order.Id)
                        exports['ox_inventory']:openInventory('stash', Order.Stash)
                    end
                },
                {
                    label = 'Aflever',
                    icon = 'fas fa-check',
                    distance = 2.0,
                    onSelect = function()
                        local Success, Error = lib.callback.await('mani-pawnshop:server:CompleteOrder', false, Order.Id)
                        if not Success then lib.notify({ title = 'Fejl', description = Error or 'Der skete en fejl.', type = 'error' }) return end
                        lib.notify({ title = 'Succes', description = 'Du har fuldført ordren.', type = 'success' })

                        local Dict = 'mp_common'
                        local Clip = 'givetake1_a'

                        lib.playAnim(Order.NPC, Dict, Clip, 8.0, 8.0, 2000, 536870912 , 0, false, false, false)

                        lib.playAnim(cache.ped, Dict, Clip, 8.0, 8.0, 2000, 14, 536870912 , false, false, false)

                        ClearOrder()
                    end
                }
            })
        end,
        onExit = function(self)
            if Order.NPC then
                exports['ox_target']:removeLocalEntity(Order.NPC)

                DeleteEntity(Order.NPC)
                Order.NPC = nil
            end
        end
    })
end)

CreateThread(function()
    Config.Jobs = {}

    for i = 1, #Config.Shops do
        local Shop = Config.Shops[i]
        Config.Jobs[Shop.Job] = i
    end
end)