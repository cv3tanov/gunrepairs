local ox_inventory = exports.ox_inventory

local active = false
local pedid
local WeaponData

RegisterNetEvent('weaponrepair:server:repair', function(weapon)
    local src = source
    local minute = 60 * 1000
    local time = Config.time * minute
    if ox_inventory:RemoveItem(src, 'money', 3000) then
        if ox_inventory:RemoveItem(src, weapon.name, 1, weapon.metadata, weapon.slot) then
            active = true
            SetTimeout(time, function()
                pedid = src
                WeaponData = weapon
            end)
        end
    else
        TriggerClientEvent('weaponrepair:client:nomoney', src)
    end
end)

lib.callback.register('weaponrepair:callback:active', function()
    return active
end)

lib.callback.register('weaponrepair:callback:getped', function(source)
    if active and pedid == source then
        return true
    else
        return false
    end
end)

RegisterNetEvent('weaponrepair:server:getitem', function()
    if WeaponData and pedid then
        WeaponData.metadata.durability = 100
        ox_inventory:AddItem(pedid, WeaponData.name, 1, { 
            serial = WeaponData.metadata.serial, 
            durability = 100, 
            ammo = WeaponData.metadata.ammo, 
            registered = WeaponData.metadata.registered, 
            components = WeaponData.metadata.components
        })
        WeaponData = nil
        pedid = nil
        active = false
    end
end)



