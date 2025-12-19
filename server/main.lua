local Config, Util = lib.load('config'), lib.load('sv_util')

local Pawnshops, Contract, Orders, InProgress = {}, {}, {}, {}

CreateThread(function()
    local SQLSuccess, SQLShops = pcall(function() return MySQL.query.await('SELECT * FROM `mani_pawnshops`') end)
    if not SQLSuccess then
        MySQL.query([[
            CREATE TABLE IF NOT EXISTS `mani_pawnshops` (
                `job` VARCHAR(25) NOT NULL DEFAULT '' COLLATE 'utf8mb4_0900_ai_ci',
                `metadata` TEXT NOT NULL DEFAULT '[]' COLLATE 'utf8mb4_0900_ai_ci',
                UNIQUE INDEX `job` (`job`) USING BTREE
            )
            COLLATE='utf8mb4_0900_ai_ci'
            ENGINE=InnoDB;
        ]])

        SQLShops = {}
    end

    for i = 1, #SQLShops do
        local ShopData = SQLShops[i]
        local Metadata = json.decode(ShopData.metadata) or {}

        Pawnshops[ShopData.job] = {
            Metadata = Metadata
        }
    end

    exports['mani-traders']:RegisterTrader('PawnshopRefiner', {
        Items = Config.Refiner.Items,
        Label = 'Refiner',
        Currency = Config.Refiner.Currency
    })

    Config.Jobs = {}

    for i = 1, #Config.Shops do
        local Shop = Config.Shops[i]
        Config.Jobs[Shop.Job] = true

        if not Pawnshops[Shop.Job] then
            MySQL.insert('INSERT INTO `mani_pawnshops` (job, metadata) VALUES (?, ?)', {
                Shop.Job, json.encode({})
            })

            Pawnshops[Shop.Job] = {
                Metadata = {}
            }
        end
    end

    while true do
        local OrderType = lib.table.deepclone(Config.Orders.Types[math.random(1, #Config.Orders.Types)])

        local OrderIndex = #Orders + 1
        OrderType.Id = OrderIndex
        OrderType.CreatedAt = os.time()

        local Items = OrderType.InterestedIn
        local UsedItems = {}
        OrderType.InterestedIn = {}

        for i = 1, OrderType.Items do
            local Item = Items[math.random(1, #Items)]
            while UsedItems[Item.Item] do
                Item = Items[math.random(1, #Items)]
            end

            Item.Amount = math.random(Item.Amount[1], Item.Amount[2])
            OrderType.InterestedIn[#OrderType.InterestedIn + 1] = Item

            UsedItems[Item.Item] = true
        end

        Orders[OrderIndex] = OrderType

        SetTimeout(Config.Orders.Expire * 60 * 1000, function()
            Orders[OrderIndex] = nil
        end)

        Wait(math.random(Config.Orders.Interval[1], Config.Orders.Interval[2]) * 1000 * 60)
    end
end)

local function AddXP(Job, Amount)
    Pawnshops[Job].Metadata.XP = (Pawnshops[Job].Metadata.XP or 0) + Amount

    MySQL.update.await('UPDATE `mani_pawnshops` SET `metadata` = ? WHERE `job` = ?', {
        json.encode(Pawnshops[Job].Metadata),
        Job
    })
end

lib.callback.register('mani-pawnshop:server:GetOrders', function(Source) return Orders end)

lib.callback.register('mani-pawnshop:server:GetComputerData', function(Source, Data)
    local ShopId = Data.ShopId
    local Shop = Config.Shops[ShopId]

    local PawnData = Pawnshops[Shop.Job]
    if not PawnData then return {} end

    return {
        XP = PawnData.Metadata.XP or 0,
    }
end)

lib.callback.register('mani-pawnshop:server:RegisterStash', function(Source, Data)
    local Index = Data.Index
    local Job = Data.Job

    if not Index or not Job then return false end

    local TrayId = ('%s_tray_%s'):format(Job, Index)

    exports['ox_inventory']:RegisterStash(TrayId, 'Bakke', Config.Tray.Slots, Config.Tray.MaxWeight)

    return true
end)

lib.callback.register('mani-pawnshop:server:StartDumpsterContract', function(Source, Data)
    local ZoneIndex = Data.Zone
    if not ZoneIndex or type(ZoneIndex) ~= 'number' then
        Util.ACLog(Source, ('%s [%s] Forsøgte at køre en Pawnshop funktion med forkerte parameters.'):format(GetPlayerName(Source), Source))
        return {}
    end

    local DConfig = Config.Contracts['DumpsterDive']
    local Zone = DConfig.Zones[ZoneIndex]

    if not Zone then
        Util.ACLog(Source, ('%s [%s] Forsøgte at starte en DumpsterDive kontrakt med en ugyldig zone index (%s).'):format(GetPlayerName(Source), Source, tostring(ZoneIndex)))
        return {}
    end

    Contract[Source] = {
        Type = 'DumpsterDive',
        Dumpsters = math.random(Zone.Dumpsters[1], Zone.Dumpsters[2]),
        XP = math.random(DConfig.XP[1], DConfig.XP[2]),
        Looted = 0
    }

    Util.Log(Source, ('Startede en DumpsterDive kontrakt i zone %s med %s dumpsters.'):format(tostring(ZoneIndex), tostring(Contract[Source].Dumpsters)))

    return Contract[Source]
end)

lib.callback.register('mani-pawnshop:server:SearchDumpster', function(Source, Data)
    local PlayerData = exports['mani-bridge']:GetPlayerData(Source)
    if not PlayerData then return false, 'Kunne ikke hente spillerdata.' end

    if not Config.Jobs[PlayerData.Job.Name] then
        Util.ACLog(Source, ('%s [%s] Forsøgte at køre en Pawnshop funktion uden at have et whitelisted job.'):format(GetPlayerName(Source), Source))
        return false, 'Der skete en fejl.'
    end

    local Entity = NetworkGetEntityFromNetworkId(Data.NetId)
    if not Entity or not DoesEntityExist(Entity) then return false, 'Entiteten findes ikke.' end

    local ContractData = Contract[Source]
    if not ContractData then
        Util.ACLog(Source, ('%s [%s] Forsøgte at søge i en dumpster uden en aktiv kontrakt.'):format(GetPlayerName(Source), Source))
        return false, 'Der skete en fejl.'
    end

    if ContractData.Type ~= 'DumpsterDive' then
        Util.ACLog(Source, ('%s [%s] Forsøgte at søge i en dumpster med en forkert kontrakt type (%s).'):format(GetPlayerName(Source), Source, tostring(ContractData.Type)))
        return false, 'Der skete en fejl.'
    end

    ContractData.Looted = ContractData.Looted + 1

    local Reward = Config.Contracts.DumpsterDive.Reward
    local Amount = math.random(Reward.Amount[1], Reward.Amount[2])

    exports['ox_inventory']:AddItem(Source, Reward.Item, Amount))

    if ContractData.Looted >= ContractData.Dumpsters then
        AddXP(PlayerData.Job.Name, ContractData.XP * ContractData.Dumpsters)

        Util.Log(Source, ('Færdiggjorde en DumpsterDive kontrakt og modtog %s XP.'):format(tostring(ContractData.XP * ContractData.Dumpsters)))
        
        Contract[Source] = nil
    else
        Util.Log(Source, ('Looted en dumpster og modtog %s x %s.'):format(tostring(Amount), Reward.Item))
    end

    return true
end)

lib.callback.register('mani-pawnshop:server:AcceptOrder', function(Source, Data)
    local OrderId = Data.OrderId
    if not OrderId or type(OrderId) ~= 'number' then
        Util.ACLog(Source, ('%s [%s] Forsøgte at acceptere en ordre med forkerte parameters.'):format(GetPlayerName(Source), Source))
        return false, 'Der skete en fejl.'
    end

    local PlayerData = exports['mani-bridge']:GetPlayerData(Source)
    if not PlayerData then return false, 'Kunne ikke hente spillerdata.' end

    if not Config.Jobs[PlayerData.Job.Name] then
        Util.ACLog(Source, ('%s [%s] Forsøgte at acceptere en ordre uden at have et whitelisted job.'):format(GetPlayerName(Source), Source))
        return false, 'Der skete en fejl.'
    end

    local Order = Orders[OrderId]
    if not Order then return false, 'Denne ordre findes ikke længere.' end

    Order.Job = PlayerData.Job.Name

    InProgress[Source] = Order

    Orders[OrderId] = nil

    Util.Log(Source, ('%s accepterede ordre %s.'):format(GetPlayerName(Source), tostring(OrderId)))

    return Order
end)

lib.callback.register('mani-pawnshop:server:RegisterTempStash', function(Source, OrderId)
    local Order = InProgress[Source]
    if not Order or Order.Id ~= OrderId then
        Util.ACLog(Source, ('%s [%s] Forsøgte at registrere en stash for en ordre de ikke har accepteret.'):format(GetPlayerName(Source), Source))
        return false, 'Der skete en fejl.'
    end

    Order.Stash = exports['ox_inventory']:CreateTemporaryStash({
        label = 'Materiale Ordre',
        slots = 5,
        maxWeight = 50000
    })

    return Order.Stash
end)

lib.callback.register('mani-pawnshop:server:CompleteOrder', function(Source)
    local Order = InProgress[Source]
    if not Order then
        Util.ACLog(Source, ('%s [%s] Forsøgte at fuldføre en ordre de ikke har accepteret.'):format(GetPlayerName(Source), Source))
        return false, 'Der skete en fejl.'
    end

    for i = 1, #Order.InterestedIn do
        local Item = Order.InterestedIn[i]
        local ItemCount = exports['ox_inventory']:Search(Order.Stash, 'count', Item.Item)

        if ItemCount < Item.Amount then
            return false, 'Du mangler nogle af de nødvendige genstande for at fuldføre ordren.'
        end
    end

    for i = 1, #Order.InterestedIn do
        local Item = Order.InterestedIn[i]

        if exports['ox_inventory']:RemoveItem(Source, Item.Item, Item.Amount, Order.Stash) then
            Util.AddMoneyForJob(Order.Job, Config.Orders.Worth[Item.Item] * Item.Amount)

            Util.Log(Source, ('Afleverede %s x %s for ordre %s.'):format(tostring(Item.Amount), Item.Item, tostring(Order.Id)))
        end
    end

    InProgress[Source] = nil

    return true
end)