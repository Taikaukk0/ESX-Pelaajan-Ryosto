ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

function IsAbleToSteal(targetSID, err)
	ESX.TriggerServerCallback('esx_ukkorosto:getValue', function(result)
		local result = result
		if result.value then
			err(false)
		else
			err(_U('no_hands_up'))
		end
	end, targetSID)
end

function OpenStealMenu(target, target_id)
	TriggerEvent('esx_ukkorosto:emote22')
	ExecuteCommand( "e bumbin" )
	palkki420()
	Citizen.Wait(1500)

	ESX.UI.Menu.CloseAll()

	ESX.TriggerServerCallback('esx_ukkorosto:getOtherPlayerData', function(data)
		local elements = {}

		if Config.Rahat then
			table.insert(elements, {
				label = (('[%s] $%s'):format(_U('cash'), ESX.Math.GroupDigits(data.money))),
				value = 'money',
				type = 'item_money',
				amount = data.money
			})
		end

		if Config.Likainen then
			local blackMoney = 0

			for i=1, #data.accounts, 1 do
				if data.accounts[i].name == 'black_money' then
					blackMoney = data.accounts[i].money
					break
				end
			end

			table.insert(elements, {
				label = (('[%s] $%s'):format(_U('black_money'), ESX.Math.GroupDigits(blackMoney))),
				value = 'black_money',
				type = 'item_account',
				amount = blackMoney
			})
		end

		if Config.Aseet then
			table.insert(elements, {label = '--- ' .. _U('guns_label') .. ' ---', value = nil})

			for i=1, #data.weapons, 1 do
				table.insert(elements, {
					label    = _U('confiscate_weapon', ESX.GetWeaponLabel(data.weapons[i].name), data.weapons[i].ammo),
					value    = data.weapons[i].name,
					itemType = 'item_weapon',
					amount   = data.weapons[i].ammo
				})
			end
		end

		if Config.Invi then
			table.insert(elements, {label = '--- ' .. _U('inventory') .. ' ---', value = nil})

			for i=1, #data.inventory, 1 do
				if data.inventory[i].count > 0 then
					table.insert(elements, {
						label = data.inventory[i].label .. ' x' .. data.inventory[i].count,
						value = data.inventory[i].name,
						type  = 'item_standard',
						amount = data.inventory[i].count,
					})
				end
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'steal_inventory', {
			title  = _U('target_inventory'),
			elements = elements,
			align = 'right'
		}, function(data, menu)

			if data.current.value ~= nil then

				local itemType = data.current.type
				local itemName = data.current.value
				local amount   = data.current.amount
				local elements = {}
				table.insert(elements, {label = _U('steal'), action = 'steal', itemType, itemName, amount})
				table.insert(elements, {label = _U('return'), action = 'return'})

				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'steal_inventory_item', {
					title = _U('action_choice'),
					align = 'right',
					elements = elements
				}, function(data2, menu2)
					if data2.current.action == 'steal' then

						if itemType == 'item_standard' then
							ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'steal_inventory_item_standard', {
								title = _U('amount')
							}, function(data3, menu3)
								local quantity = tonumber(data3.value)
								TriggerServerEvent('esx_ukkorosto:stealPlayerItem', GetPlayerServerId(target), itemType, itemName, quantity)
								OpenStealMenu(target)
							
								menu3.close()
								menu2.close()
							end, function(data3, menu3)
								menu3.close()
							end)
						else
							TriggerServerEvent('esx_ukkorosto:stealPlayerItem', GetPlayerServerId(target), itemType, itemName, amount)
							OpenStealMenu(target)
						end

					elseif data2.current.action == 'return' then
						ESX.UI.Menu.CloseAll()
						OpenStealMenu(target)
					end

				end, function(data2, menu2)
					menu2.close()
				end)
			end

		end, function(data, menu)
			menu.close()
		end)
	end, GetPlayerServerId(target))
end

function palkki420()
	TriggerEvent("mythic_progbar:client:progress", {
        name = "unique_action_name",
        duration = 2000,
        label = "Tutkitaan pelaajan taskuja...",
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
    }, function(status)
        if not status then
        end
	end)
end

RegisterNetEvent('esx_ukkorosto:emote22')
AddEventHandler('esx_ukkorosto:emote22', function()
	if IsControlJustPressed(0, 322) or IsControlJustReleased(0, 177) then
		ClearPedTasks(playerPed)
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		local ped = PlayerPedId()

		if IsControlJustPressed(0, 47) and IsPedArmed(ped, 7) and not IsEntityDead(ped) and IsPedOnFoot(ped) then
			local target, distance = ESX.Game.GetClosestPlayer()

			if target ~= -1 and distance ~= -1 and distance <= 2.0 then
				local target_id = GetPlayerServerId(target)
				
				IsAbleToSteal(target_id, function(err)
					if(not err)then
						OpenStealMenu(target, target_id)
					else
						ESX.ShowNotification(err)
					end
				end)
			elseif distance < 20 and distance > 2.0 then
				ESX.ShowNotification(_U('Olet liian kaukana!'))
			else
				ESX.ShowNotification(_U('Kenet meinasit ryostaa??'))
			end
		end
	end
end)