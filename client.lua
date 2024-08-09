local Wash = false
local TimeWait =  false
local ox_target = exports.ox_target

function Time()
	TimeWait = true
	Wait(60 * 1000)
	TimeWait = false
end

function WashingMoney()
local playerPed = cache.ped or PlayerPedId()
    if Wash then
        lib.notify({
            title = 'Перачев',
            description = 'Вече перете пари',
			position = 'center-left',
            type = 'error'
        })
    else
        if not TimeWait then
            lib.requestAnimDict('anim@gangops@facility@servers@bodysearch@', 10)
            TaskPlayAnim(playerPed, 'anim@gangops@facility@servers@bodysearch@', 'player_search', 8.0, -8.0, -1, 48, 0)
			
            local input = lib.inputDialog('Перачев Меню', {
				{
					type = 'number', 
					label = 'Минимално количество', 
					min = 10000,
					max = 100000, 
					description = 'Мин. 10 000 Макс 100 000 Маркирани пари', 
					icon = 'fa-solid fa-sack-dollar'
				},
			})
    
            if not input then return end
            local WashAmount = tonumber(input[1])    
            TriggerServerEvent('jd-moneywash:washAmount', WashAmount)
            Wait(500)
            ClearPedTasksImmediately(playerPed)
        else
            lib.notify({
                title = 'Перачев',
                --description = 'Трябва да изчакате '..Config.time..' минута',
				description = 'Вече сте ползвали нашите услуги елате пак по късно!',
				position = 'center-left',
                type = 'error'
            })
        end
    end
end

RegisterNetEvent('jd-moneywash:startWashing', function()
local playerPed = cache.ped or PlayerPedId()
    Wash = true
		lib.notify({
			title = 'Перачев',
			description = 'Започнали сте процеса на пране',
			position = 'center-left',
			type = 'inform'
		})
	Wait(1000)
	TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_AA_SMOKE")
	if lib.progressCircle({
		duration = Config.WashDuration,
		position = 'bottom',
		label = 'Изчакайте да ви изчистят парите',
		useWhileDead = false,
		canCancel = false,
	}) then 
		lib.notify({
			title = 'Перачев',
			description = 'Парите са ви чисто нови...',
			position = 'center-left',
			type = 'inform'
		}) 
	end
	Wash = false
	ClearPedTasks(playerPed)
    Time()
end)

ox_target:addSphereZone({
	name = "money",
	coords = vec3(636.55, 2786.3, 42.2),
	radius = 0.7,
	options = {
		{ 
			icon = "fa-solid fa-sack-dollar",
			label = 'Пералня', 
			distance = 2.5,
			onSelect = function()
				WashingMoney()
			end,
		}
	}
})