local QBCore = exports['qb-core']:GetCoreObject()

-- Create blips for all oil pumps
CreateThread(function()
    for _, pump in pairs(Config.OilPumps) do
        local blip = AddBlipForCoord(pump.coords.x, pump.coords.y, pump.coords.z)
        SetBlipSprite(blip, 436)
        SetBlipScale(blip, 0.8)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Oil Pump")
        EndTextCommandSetBlipName(blip)
    end
end)

CreateThread(function()
    local model = GetHashKey(Config.PedType)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end
    
    -- Create the ped
    local coords = vector4(598.27, 2930.26, 39.91, 65.27)
    local ped = CreatePed(4, model, coords.x, coords.y, coords.z, coords.w, false, true)
    SetEntityHeading(ped, coords.w)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    
    -- Add targeting
    exports['qb-target']:AddTargetEntity(ped, {
        options = {
            {
                num = 1,
                type = "server",
                event = "republic-fueljob:server:checkCash",
                icon = "fas fa-truck",
                label = "Rent Truck ($" .. Config.TruckPrice .. ")",
                job = {"trucker", "grime"}
            },
            {
                num = 2,
                type = "server",
                event = "republic-fueljob:server:ownedTruck",
                icon = "fas fa-gas-pump",
                label = "Use Own Truck ($" .. Config.TankPrice .. ")",
                job = {"trucker", "grime"}
            },
            {
                num = 3,
                type = "server",
                event = "republic-fueljob:server:getTruckerPay",
                icon = "fas fa-money-bill",
                label = "Collect Paycheck",
                job = {"trucker", "grime"}
            },
            {
                num = 4,
                type = "client",
                event = "republic-fueljob:client:restartJob",
                icon = "fas fa-redo",
                label = "Restart Job",
                job = {"trucker", "grime"}
            },
            {
                num = 5,
                type = "client",
                event = "republic-fueljob:client:cancelJob",
                icon = "fas fa-times",
                label = "Cancel Job",
                job = {"trucker", "grime"}
            }
        },
        distance = 2.0
    })
end)


-- Add spawn events
RegisterNetEvent('spawnTruck', function()
    local vehicle = QBCore.Functions.SpawnVehicle(Config.TruckToSpawn, function(veh)
        SetVehicleNumberPlateText(veh, "OIL"..tostring(math.random(1000, 9999)))
        TriggerEvent('vehiclekeys:client:SetOwner', GetVehicleNumberPlateText(veh))
        SetEntityHeading(veh, Config.StartLocation.w)
        TriggerEvent('vehiclekeys:client:SetOwner', GetVehicleNumberPlateText(veh))
        SetVehicleEngineOn(veh, true, true)
    end, Config.StartLocation, true)
end)

RegisterNetEvent('spawnTruck2', function()
    local vehicle = QBCore.Functions.SpawnVehicle(Config.TrailerToSpawn, function(veh)
        SetVehicleNumberPlateText(veh, "TANK"..tostring(math.random(1000, 9999)))
        exports[Config.VehicleKeys]:SetVehicleKey(GetVehicleNumberPlateText(veh), true)
        SetEntityHeading(veh, Config.StartLocation.w)
        TriggerEvent('vehiclekeys:client:SetOwner', GetVehicleNumberPlateText(veh))
        SetVehicleEngineOn(veh, true, true)
    end, Config.StartLocation, true)
end)

CreateThread(function()
    exports['qb-target']:AddTargetModel('p_oil_pjack_03_s', {
        options = {
            {
                type = "client",
                event = "republic-fueljob:client:ConnectHose",
                icon = "fas fa-gas-pump",
                label = "Connect Hose",
                job = "fueler"
            },
        },
        distance = 2.5
    })
end)

RegisterNetEvent('republic-fueljob:client:ConnectHose', function()
    local ped = PlayerPedId()
    local hoseModel = -730904777
    
    RequestModel(hoseModel)
    while not HasModelLoaded(hoseModel) do Wait(0) end
    
    local hose = CreateObject(hoseModel, 0, 0, 0, true, true, true)
    AttachEntityToEntity(hose, ped, GetPedBoneIndex(ped, 57005), 0.12, 0.0, 0.0, -90.0, -90.0, 0.0, true, true, false, true, 1, true)
    
    QBCore.Functions.Progressbar("connecting_hose", "Connecting Hose...", 5000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "mini@repair",
        anim = "fixing_a_ped",
        flags = 49,
    }, {}, {}, function()
        DeleteEntity(hose)
        StartOilCollection()
    end)
end)

function StartOilCollection()
    QBCore.Functions.Progressbar("collecting_oil", "Collecting Crude Oil...", 10000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        SetNewWaypoint(Config.Refinery.x, Config.Refinery.y)
        QBCore.Functions.Notify("Tanker filled with crude oil. Head to the refinery.", "success")
    end)
end

function CreateReturnZone()
    exports['qb-target']:AddBoxZone("oil_truck_return", 
        vector3(Config.ReturnLocation.x, Config.ReturnLocation.y, Config.ReturnLocation.z), 
        6.0, 6.0, {
            name = "oil_truck_return",
            heading = Config.ReturnLocation.w,
            debugPoly = false,
            minZ = Config.ReturnLocation.z - 2,
            maxZ = Config.ReturnLocation.z + 2,
        }, {
            options = {
                {
                    type = "client",
                    event = "republic-fueljob:client:ReturnTruck",
                    icon = "fas fa-truck",
                    label = "Return Truck",
                    job = "fueler"
                },
            },
            distance = 3.0
    })
end

RegisterNetEvent('republic-fueljob:client:ReturnTruck', function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle ~= 0 then
        DeleteVehicle(vehicle)
        TriggerServerEvent('republic-fueljob:server:PayOilDelivery')
        QBCore.Functions.Notify("Job completed! Payment received.", "success")
    end
end)

CreateThread(function()
    exports['qb-target']:AddBoxZone("refinery_dropoff", 
        vector3(Config.Refinery.x, Config.Refinery.y, Config.Refinery.z), 
        2.0, 2.0, {
            name = "refinery_dropoff",
            heading = Config.Refinery.w,
            debugPoly = false,
            minZ = Config.Refinery.z - 2,
            maxZ = Config.Refinery.z + 2,
        }, {
            options = {
                {
                    type = "client",
                    event = "republic-fueljob:client:ConnectRefineryHose",
                    icon = "fas fa-gas-pump",
                    label = "Connect Refinery Hose",
                    job = "fueler"
                },
            },
            distance = 3.0
    })
end)

RegisterNetEvent('republic-fueljob:client:ConnectRefineryHose', function()
    local ped = PlayerPedId()
    local hoseModel = -730904777
    
    RequestModel(hoseModel)
    while not HasModelLoaded(hoseModel) do Wait(0) end
    
    local hose = CreateObject(hoseModel, 0, 0, 0, true, true, true)
    AttachEntityToEntity(hose, ped, GetPedBoneIndex(ped, 57005), 0.12, 0.0, 0.0, -90.0, -90.0, 0.0, true, true, false, true, 1, true)
    
    QBCore.Functions.Progressbar("connecting_refinery_hose", "Connecting Refinery Hose...", 5000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "mini@repair",
        anim = "fixing_a_ped",
        flags = 49,
    }, {}, {}, function()
        DeleteEntity(hose)
        StartRefining()
    end)
end)

function StartRefining()
    QBCore.Functions.Progressbar("refining_oil", "Refining Crude Oil...", 15000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        SetNewWaypoint(Config.StartLocation.x, Config.StartLocation.y)
        QBCore.Functions.Notify("Oil refined into gasoline. Return the truck to receive payment.", "success")
    end)
end

RegisterNetEvent('republic-fueljob:client:restartJob', function()
    TriggerServerEvent('republic-fueljob:server:restartJob')
    QBCore.Functions.Notify('Job restarted!', 'success')
end)

RegisterNetEvent('republic-fueljob:client:cancelJob', function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle ~= 0 then
        DeleteVehicle(vehicle)
    end
    QBCore.Functions.Notify('Job cancelled!', 'error')
end)
