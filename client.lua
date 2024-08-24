local ox_inventory = exports.ox_inventory
local ox_target = exports.ox_target

local WeaponData = {}
local itsme
local active = false

function SpawnPed()
    if pedSpawned then return end
    local model = joaat(Config.model)
        lib.requestModel(model)
    local coords = Config.coords4
    local gunped = CreatePed(0, model, coords.x, coords.y, coords.z-1.0, coords.w, false, false)

    spawnedPed = gunped

    TaskStartScenarioInPlace(gunped, 'PROP_HUMAN_STAND_IMPATIENT', 0, true)
    FreezeEntityPosition(gunped, true)
    SetEntityInvincible(gunped, true)
    SetBlockingOfNonTemporaryEvents(gunped, true)

    pedSpawned = true

    ox_target:addLocalEntity(gunped, {
        {
            name = 'weaponrepair',
            label = 'Ремонт на оръжие',
            event = 'weaponrepair:client:targetted',
            icon = 'fa-sharp fa-solid fa-gun',
            canInteract = function(_, distance)
                return distance < 2.0
            end
        }
    })

end

CreateThread(function()
    SpawnPed()
end)

RegisterNetEvent('weaponrepair:client:targetted', function()
    active = lib.callback.await('weaponrepair:callback:active', false)
    itsme = lib.callback.await('weaponrepair:callback:getped', false)
    Wait(250)
    lib.registerContext({
        id = 'repairmenu',
        title = 'Ремонт меню',
        onExit = function()
            lib.notify({
                title = 'Гошо Далаверата',
                description = 'Хм..Проверяваш ли ме? Да не си уше? Марш от тук щом няма какво да поправям',
                type = 'inform',
                duration = 5000,
                position = 'center-left'
            })
        end,
        options = {
            {
                title = 'Ремонт на оръжие',
                disabled = active,
                description = 'Дай ми оръжието си и ще ти го поправя!',
                icon = 'fa-solid fa-gun',
                onSelect = function(args)
                    lib.notify({
                        title = 'Гошо Далаверата',
                        description = 'Благодаря че използвате услугите ми! Това ще отнеме '..tostring(Config.time)..' минути! Моля изчакайте наблизо!',
                        type = 'success',
                        duration = 5000,
                        position = 'center-left'
                    })
                end,
                event = 'weaponrepair:client:repair',
                args = {
                    type = 'repair'
                },
                metadata = {
                    {
                        label = 'Цена', 
                        value = '$3000'
                    }
                }
            },
            {
                title = 'Вземи оръжие',
                disabled = not itsme,
                description = 'Вземи си оръжието',
                icon = 'fa-solid fa-hand',
                onSelect = function(args)
                    lib.notify({
                        title = 'Гошо Далаверата',
                        description = 'Благодаря че използвахте услугите ми!',
                        type = 'success',
                        position = 'center-left'
                    })
                end,
                event = 'weaponrepair:client:repair',
                args = {
                    type = 'get'
                }
            },
        }
    })
    if ox_inventory:getCurrentWeapon() or itsme then
        lib.showContext('repairmenu')
    else
        lib.notify({
            title = 'Гошо Далаверата',
            description = 'Покажете ми оръжието за да видя какво му има!',
            duration = 5000,
            type = 'error',
            position = 'center-left'
        })
    end
end)

RegisterNetEvent('weaponrepair:client:nomoney', function()
    lib.notify({
        title = 'Гошо Далаверата',
        description = 'Нямате достатъчно пари за този ремонт!',
        type = 'error',
        position = 'center-left'
    })
end)

RegisterNetEvent('weaponrepair:client:repair', function(data)
    if data.type == 'repair' then
        local weapon = ox_inventory:getCurrentWeapon()
        if weapon then
            TriggerEvent('ox_inventory:disarm')
            Wait(1500)
            TriggerServerEvent('weaponrepair:server:repair', weapon)
        end
    elseif data.type == 'get' then 
        TriggerServerEvent('weaponrepair:server:getitem')
        active = false
        itsme = false
    end      
end)
