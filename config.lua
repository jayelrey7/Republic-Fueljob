Config = {}

-- Debug Settings
Config.Debug = false

-- Location Settings
Config.Blip = {
    {
        title = "Oil Refinery",
        color = 12,
        id = 477,
        x = 598.27,
        y = 2930.26,
        z = 40.91,
    },
}

Config.OilPumps = {
    {coords = vector4(694.04, 2884.62, 50.13, 328.71)},
    {coords = vector4(608.11, 2854.51, 39.99, 351.49)},
    {coords = vector4(654.07, 2924.03, 42.1, 130.7)},
    {coords = vector4(650.11, 3015.86, 43.32, 203.48)},
    {coords = vector4(600.75, 3018.11, 41.95, 61.22)},
    {coords = vector4(579.65, 2925.3, 40.89, 353.68)},
    {coords = vector4(544.72, 2875.93, 43.06, 61.51)},
    {coords = vector4(494.89, 2961.67, 42.28, 262.37)}
}

Config.Refinery = vector4(2675.44, 1491.88, 24.5, 102.43)
Config.ReturnLocation = vector4(617.96, 2928.02, 40.19, 3.63)
Config.OilCollection = vector4(1686.17, -1457.77, 112.39, 254.5)

-- Framework Settings
Config.Target = 'qb'
Config.UseMenu = false
Config.Menu = 'qb'
Config.VehicleKeys = 'qb-vehiclekeys'
Config.FuelScript = 'LegacyFuel'

-- Vehicle Settings
Config.PedType = "s_m_m_dockwork_01"  -- Changed to dock worker model
Config.TruckToSpawn = "packer"
Config.TrailerToSpawn = "tanker2"
Config.OilTankerModel = 'tanker'

-- Payment Settings
Config.PayType = 'bank'
Config.TankPrice = 2000
Config.OilJobPay = 1250
Config.OilTruckPrice = 1500
Config.OilCollectionPay = 500

-- Added Missing Required Configs
Config.TruckPrice = 2500 -- Added missing truck rental price
Config.PayPerDelivery = 750 -- Added missing delivery payment
Config.PayPerFueling = 250 -- Added missing fueling payment
Config.StartLocation = vector4(617.96, 2928.02, 40.19, 3.63) -- Added missing start location

return Config
