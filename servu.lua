ESX = nil
local Users = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('esx_ukkorosto:getValue', function(source, cb, targetSID)
	if Users[targetSID] then
		cb(Users[targetSID])
	else
		cb({value = false, time = 0})
	end
end)

ESX.RegisterServerCallback('esx_ukkorosto:getOtherPlayerData', function(source, cb, target)
	local xPlayer = ESX.GetPlayerFromId(target)

	local data = {
		name = GetPlayerName(target),
		inventory = xPlayer.inventory,
		accounts = xPlayer.accounts,
		money = xPlayer.getMoney()
	}

	cb(data)
end)

RegisterServerEvent('esx_ukkorosto:stealPlayerItem')
AddEventHandler('esx_ukkorosto:stealPlayerItem', function(target, itemType, itemName, amount)
	local _source = source
	local sourceXPlayer = ESX.GetPlayerFromId(_source)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if itemType == 'item_standard' then

		local label = sourceXPlayer.getInventoryItem(itemName).label
		local itemLimit = sourceXPlayer.getInventoryItem(itemName).limit
		local sourceItemCount = sourceXPlayer.getInventoryItem(itemName).count
		local targetItemCount = targetXPlayer.getInventoryItem(itemName).count

		if amount > 0 and targetItemCount >= amount then
			if itemLimit ~= -1 and (sourceItemCount + amount) > itemLimit then
				TriggerClientEvent('esx:showNotification', targetXPlayer.source, _U('ex_inv_lim_target'))
				TriggerClientEvent('esx:showNotification', sourceXPlayer.source, _U('ex_inv_lim_source'))
			else
				targetXPlayer.removeInventoryItem(itemName, amount)
				sourceXPlayer.addInventoryItem(itemName, amount)

				TriggerClientEvent('esx:showNotification', sourceXPlayer.source, _U('you_stole') .. ' ~g~x' .. amount .. ' ' .. label .. ' ~w~' .. _U('from_your_target') )
				TriggerClientEvent('esx:showNotification', targetXPlayer.source, _U('someone_stole') .. ' ~r~x'  .. amount .. ' ' .. label )
			end
		else
			TriggerClientEvent('esx:showNotification', _source, _U('invalid_quantity'))
		end

	elseif itemType == 'item_money' then

		if amount > 0 and targetXPlayer.get('money') >= amount then
			targetXPlayer.removeMoney(amount)
			sourceXPlayer.addMoney(amount)

			TriggerClientEvent('esx:showNotification', sourceXPlayer.source, _U('you_stole') .. ' ~g~$' .. amount .. ' ~w~' .. _U('from_your_target') )
			TriggerClientEvent('esx:showNotification', targetXPlayer.source, _U('someone_stole') .. ' ~r~$'  .. amount )
		else
			TriggerClientEvent('esx:showNotification', _source, _U('imp_invalid_amount'))
		end

	elseif itemType == 'item_account' then

		if amount > 0 and targetXPlayer.getAccount(itemName).money >= amount then
			targetXPlayer.removeAccountMoney(itemName, amount)
			sourceXPlayer.addAccountMoney(itemName, amount)

			TriggerClientEvent('esx:showNotification', sourceXPlayer.source, _U('you_stole') .. ' ~g~$' .. amount .. ' ~w~' .. _U('of_black_money') .. ' ' .. _U('from_your_target') )
			TriggerClientEvent('esx:showNotification', targetXPlayer.source, _U('someone_stole') .. ' ~r~$'  .. amount .. ' ~w~' .. _U('of_black_money') )
		else
			TriggerClientEvent('esx:showNotification', _source, _U('imp_invalid_amount'))
		end

	end
end)

RegisterServerEvent('esx_ukkorosto:update')
AddEventHandler('esx_ukkorosto:update', function(bool)
	local _source = source
	Users[_source] = {value = bool, time = os.time()}
end)

RegisterServerEvent('esx_ukkorosto:getValue')
AddEventHandler('esx_ukkorosto:getValue', function(targetSID)
	local _source = source
	if Users[targetSID] then
		TriggerClientEvent('esx_ukkorosto:returnValue', _source, Users[targetSID])
	else
		TriggerClientEvent('esx_ukkorosto:returnValue', _source, Users[targetSID])
	end
end)