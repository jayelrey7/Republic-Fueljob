local QBCore = exports['qb-core']:GetCoreObject()

-- Default fallback values
Config.PayPerDelivery = Config.PayPerDelivery or 500
Config.PayPerFueling = Config.PayPerFueling or 250

-- Optimized server callbacks
local function RegisterServerCallbacks()
    QBCore.Functions.CreateCallback('republic-fueljob:server:verifyJob', function(source, cb)
        local Player = QBCore.Functions.GetPlayer(source)
        if Player.PlayerData.job.name == "fueler" then
            cb(true)
        else
            cb(false)
        end
    end)
end

RegisterServerEvent('republic-fueljob:server:checkCash')
AddEventHandler('republic-fueljob:server:checkCash', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local moneyType = Config.PayType
    local balance = Player.Functions.GetMoney(moneyType)

    if balance >= Config.TruckPrice then
        Player.Functions.RemoveMoney(moneyType, Config.TruckPrice, "gas-delivery-truck")
        TriggerClientEvent('spawnTruck', src)
        TriggerClientEvent('TrailerBlip', src)
    else
        TriggerClientEvent('NotEnoughTruckMoney', src)
    end
end)

RegisterServerEvent('republic-fueljob:server:ownedTruck')
AddEventHandler('republic-fueljob:server:ownedTruck', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local moneyType = Config.PayType
    local balance = Player.Functions.GetMoney(moneyType)

    if balance >= Config.TankPrice then
        Player.Functions.RemoveMoney(moneyType, Config.TankPrice, "gas-Tank-truck")
        TriggerClientEvent('spawnTruck2', src)
        TriggerClientEvent('TrailerBlip', src)
    else
        TriggerClientEvent('NotEnoughTankMoney', src)
    end 
end)

RegisterServerEvent('republic-fueljob:server:getPaid')
AddEventHandler('republic-fueljob:server:getPaid', function(stationsRefueled)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    Player.Functions.AddMoney(Config.PayType, stationsRefueled * Config.PayPerFueling, "gas-delivery-paycheck")
end)

RegisterNetEvent('republic-fueljob:server:PayOilDelivery')
AddEventHandler('republic-fueljob:server:PayOilDelivery', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local payment = Config.OilJobPay
    Player.Functions.AddMoney('bank', payment, 'oil-delivery-payment')
    TriggerClientEvent('QBCore:Notify', src, 'You received $'..payment..' for the oil delivery', 'success')
end)

RegisterServerEvent('republic-fueljob:server:checkOilTruckPayment')
AddEventHandler('republic-fueljob:server:checkOilTruckPayment', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local moneyType = Config.PayType
    local balance = Player.Functions.GetMoney(moneyType)

    if balance >= Config.OilTruckPrice then
        Player.Functions.RemoveMoney(moneyType, Config.OilTruckPrice, "oil-truck-rental")
        TriggerClientEvent('republic-fueljob:client:StartOilRoute', src)
    else
        TriggerClientEvent('QBCore:Notify', src, 'You need $'..Config.OilTruckPrice..' to rent an oil truck!', 'error')
    end
end)

RegisterServerEvent('republic-fueljob:server:verifyOilCollection')
AddEventHandler('republic-fueljob:server:verifyOilCollection', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local currentJob = Player.PlayerData.job.name
    
    if currentJob == "fueler" then
        TriggerClientEvent('republic-fueljob:client:startOilCollection', src)
    else
        TriggerClientEvent('QBCore:Notify', src, 'You need to be a fueler to collect oil!', 'error')
    end
end)

RegisterServerEvent('republic-fueljob:server:payOilCollection')
AddEventHandler('republic-fueljob:server:payOilCollection', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local payment = Config.OilCollectionPay * amount
    Player.Functions.AddMoney(Config.PayType, payment, 'oil-collection-payment')
    TriggerClientEvent('QBCore:Notify', src, 'You received $'..payment..' for the oil collection!', 'success')
end)

RegisterNetEvent('republic-fueljob:server:getTruckerPay')
AddEventHandler('republic-fueljob:server:getTruckerPay', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local stationsRefueled = Player.PlayerData.metadata.stationsRefueled or 0
    local payment = Config.PayPerDelivery * stationsRefueled
    
    if payment > 0 then
        Player.Functions.AddMoney('bank', payment)
        TriggerClientEvent('QBCore:Notify', src, 'You received $'..payment..' for your deliveries!', 'success')
        
        Player.PlayerData.metadata.stationsRefueled = 0
        Player.Functions.SetMetaData('stationsRefueled', 0)
    end
end)

RegisterNetEvent('republic-fueljob:server:restartJob')
AddEventHandler('republic-fueljob:server:restartJob', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    Player.PlayerData.metadata.stationsRefueled = 0
    Player.Functions.SetMetaData('stationsRefueled', 0)
    
    TriggerClientEvent('republic-fueljob:client:restartJob', src)
end)

-- Initialize callbacks
CreateThread(function()
    RegisterServerCallbacks()
end)
