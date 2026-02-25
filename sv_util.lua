local Util  = {}

local Webhook = nil
local ACWebhook = exports['elevate-confidential']:fetch('ac_webhook')

function Util.AddMoneyForJob(Job, Amount, TransactionData)
    exports['elevate-multijob']:addAccountBalance(Job, Amount)
    exports['fh_bossmenu']:AddIncome(Job, { amount = Amount, type = 'income', description = TransactionData.Reason }, TransactionData.Name)
end

function Util.RemoveMoneyForJob(Job, Amount)
    exports['elevate-multijob']:removeAccountBalance(Job, Amount)
end

function Util.GetJobAccount(Job)
    return exports['elevate-multijob']:getAccountBalance(Job)
end

function Util.Log(Source, Message)
    exports['onl_logsender']:SendLog(Source, Message, {
        labels = {
            job = "logs",
            discordId = true,
            steamId = true,
            license = true,
            playerJob = true,
            jobGrade = true,
            playerName = true,
            screenshot = false,
            money = true,
            black_money = true,
            bank = true,
            coords = true,
            radio = true,
        },
        discordTitle = Message,
        discordWebhook = Webhook
    })
end

function Util.ACLog(Source, Message)
    exports['onl_logsender']:SendLog(Source, Message, {
        labels = {
            job = "logs",
            discordId = true,
            steamId = true,
            license = true,
            playerJob = true,
            jobGrade = true,
            playerName = true,
            screenshot = false,
            money = true,
            black_money = true,
            bank = true,
            coords = true,
            radio = true,
        },
        discordTitle = Message,
        discordWebhook = ACWebhook
    })
end

return Util