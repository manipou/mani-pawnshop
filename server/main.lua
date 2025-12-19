local Config = lib.load('config')

local Pawnshops, Contract, Orders = {}, {}, {}

local ACWebhook = exports['elevate-confidential']:fetch('ac_webhook')

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
        print(json.encode(ShopData))
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

    -- Config.WhitelistedModels = {}

    -- for _, Model in pairs(Config.Contracts.DumpsterDive.DumpsterProps) do
    --     Config.WhitelistedModels[GetHashKey(Model)] = true
    -- end
end)

local function ACLog(Source, Message)
    print(Message)
end

local function Log(Source, Message)

end

local function AddXP(Job, Amount)
    Pawnshops[Job].Metadata.XP = (Pawnshops[Job].Metadata.XP or 0) + Amount

    MySQL.update.await('UPDATE `mani_pawnshops` SET `metadata` = ? WHERE `job` = ?', {
        json.encode(Pawnshops[Job].Metadata),
        Job
    })
end

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
        ACLog(Source, ('%s [%s] Forsøgte at køre en Pawnshop funktion med forkerte parameters.'):format(GetPlayerName(Source), Source))
        return {}
    end

    local DConfig = Config.Contracts['DumpsterDive']
    local Zone = DConfig.Zones[ZoneIndex]

    if not Zone then
        ACLog(Source, ('%s [%s] Forsøgte at starte en DumpsterDive kontrakt med en ugyldig zone index (%s).'):format(GetPlayerName(Source), Source, tostring(ZoneIndex)))
        return {}
    end

    Contract[Source] = {
        Type = 'DumpsterDive',
        Dumpsters = math.random(Zone.Dumpsters[1], Zone.Dumpsters[2]),
        XP = math.random(DConfig.XP[1], DConfig.XP[2]),
        Looted = 0
    }

    return Contract[Source]
end)

lib.callback.register('mani-pawnshop:server:SearchDumpster', function(Source, Data)
    local PlayerData = exports['mani-bridge']:GetPlayerData(Source)
    if not PlayerData then return false, 'Kunne ikke hente spillerdata.' end

    if not Config.Jobs[PlayerData.Job.Name] then
        ACLog(Source, ('%s [%s] Forsøgte at køre en Pawnshop funktion uden at have et whitelisted job.'):format(GetPlayerName(Source), Source))
        return false, 'Der skete en fejl.'
    end

    local Entity = NetworkGetEntityFromNetworkId(Data.NetId)
    if not Entity or not DoesEntityExist(Entity) then return false, 'Entiteten findes ikke.' end

    local ContractData = Contract[Source]
    if not ContractData then
        ACLog(Source, ('%s [%s] Forsøgte at søge i en dumpster uden en aktiv kontrakt.'):format(GetPlayerName(Source), Source))
        return false, 'Der skete en fejl.'
    end

    if ContractData.Type ~= 'DumpsterDive' then
        ACLog(Source, ('%s [%s] Forsøgte at søge i en dumpster med en forkert kontrakt type (%s).'):format(GetPlayerName(Source), Source, tostring(ContractData.Type)))
        return false, 'Der skete en fejl.'
    end

    ContractData.Looted = ContractData.Looted + 1

    local Reward = Config.Contracts.DumpsterDive.Reward
    local Amount = math.random(Reward.Amount[1], Reward.Amount[2])

    exports['ox_inventory']:AddItem(Source, Reward.Item, Amount)

    if ContractData.Looted >= ContractData.Dumpsters then
        AddXP(PlayerData.Job.Name, ContractData.XP * ContractData.Dumpsters)
        
        Contract[Source] = nil
    end

    return true
end)