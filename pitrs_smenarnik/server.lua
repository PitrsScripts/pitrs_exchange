local ESX = exports['es_extended']:getSharedObject()



ESX.RegisterServerCallback('pitrs_smenarnik:checkItem', function(source, cb, itemName, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then cb(false) return end
    
    local item = xPlayer.getInventoryItem(itemName)
    if not item or item.count < amount then
        cb(false)
    else
        cb(true)
    end
end)

RegisterServerEvent('pitrs_smenarnik:sellItem')
AddEventHandler('pitrs_smenarnik:sellItem', function(itemName, amount, price)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    local item = xPlayer.getInventoryItem(itemName)
    if not item or item.count < amount then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Error',
            description = 'You don\'t have enough items',
            type = 'error'
        })
        TriggerClientEvent('pitrs_smenarnik:playNoItemsAnim', source)
        return
    end
    xPlayer.removeInventoryItem(itemName, amount)
    local totalPrice = price * amount
    xPlayer.addMoney(totalPrice)
    
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Sold',
        description = string.format('You sold %dx %s for $%d', amount, item.label, totalPrice),
        type = 'success'
    })
    TriggerClientEvent('pitrs_smenarnik:playSuccessAnim', source)
end)