local ESX = exports['es_extended']:getSharedObject()
local npc = nil
local npcPosition = nil


local function SpawnNPC()
    if npc then
        DeleteEntity(npc)
    end

    npcPosition = Config.NPCPositions[math.random(#Config.NPCPositions)]
    local model = GetHashKey(Config.NPCModel)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(1)
    end

    npc = CreatePed(4, model, npcPosition.x, npcPosition.y, npcPosition.z - 1.0, 0.0, false, true)
    SetEntityHeading(npc, 0.0)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    
    exports.ox_target:addLocalEntity(npc, {
        {
            name = 'money_exchange',
            icon = 'fas fa-coins',
            label = 'Money Exchange',
            onSelect = function()
                OpenExchangeMenu()
            end
        }
    })
end


function OpenExchangeMenu()
    lib.requestAnimDict('gestures@m@standing@casual')
    TaskPlayAnim(PlayerPedId(), 'gestures@m@standing@casual', 'gesture_shrug_hard', 8.0, -8.0, -1, 1, 0, false, false, false)
    if lib.progressBar({
        duration = 1000,
        label = 'Negotiating with the exchange...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true
        }
    }) then
        ClearPedTasks(PlayerPedId())
        
        local options = {}
        
        for i, item in ipairs(Config.SellItems) do
            table.insert(options, {
                title = item.label,
                description = 'Sell for $' .. item.price,
                icon = 'fas fa-dollar-sign',
                onSelect = function()
                    SellItem(item.item, item.price)
                end
            })
        end
        
        lib.registerContext({
            id = 'exchange_menu',
            title = 'Money Exchange',
            options = options
        })
        
        lib.showContext('exchange_menu')
    else
        ClearPedTasks(PlayerPedId())
        lib.notify({
            title = 'Cancelled',
            description = 'Negotiation was interrupted',
            type = 'error'
        })
    end
end


function SellItem(itemName, price)
    local input = lib.inputDialog('Sell Item', {
        {type = 'number', label = 'Quantity', placeholder = '1', min = 1, max = 100}
    })
    if not input then return end
    local amount = tonumber(input[1])
    if not amount or amount <= 0 then
        lib.notify({
            title = 'Error',
            description = 'Invalid quantity',
            type = 'error'
        })
        return
    end

    ESX.TriggerServerCallback('pitrs_smenarnik:checkItem', function(hasItem)
        if not hasItem then
            lib.notify({
                title = 'Error',
                description = 'You don\'t have enough items',
                type = 'error'
            })
            if npc and DoesEntityExist(npc) then
                lib.requestAnimDict('gestures@m@standing@casual')
                TaskPlayAnim(npc, 'gestures@m@standing@casual', 'gesture_nod_no_hard', 8.0, -8.0, 2000, 0, 0, false, false, false)
            end
            return
        end
        lib.requestAnimDict('mp_common')
        TaskPlayAnim(PlayerPedId(), 'mp_common', 'givetake1_a', 8.0, -8.0, -1, 1, 0, false, false, false)
        
        if lib.progressBar({
            duration = 2000,
            label = 'Selling item to exchange...',
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
                move = true,
                combat = true
            }
        }) then
            ClearPedTasks(PlayerPedId())
            TriggerServerEvent('pitrs_smenarnik:sellItem', itemName, amount, price)
        else
            ClearPedTasks(PlayerPedId())
            lib.notify({
                title = 'Cancelled',
                description = 'Sale was interrupted',
                type = 'error'
            })
        end
    end, itemName, amount)
end


AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        SpawnNPC()
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if npc then
            DeleteEntity(npc)
        end
    end
end)


CreateThread(function()
    SpawnNPC()
end)

RegisterNetEvent('pitrs_smenarnik:playNoItemsAnim')
AddEventHandler('pitrs_smenarnik:playNoItemsAnim', function()
    if npc and DoesEntityExist(npc) then
        lib.requestAnimDict('gestures@m@standing@casual')
        TaskPlayAnim(npc, 'gestures@m@standing@casual', 'gesture_nod_no_hard', 8.0, -8.0, 2000, 0, 0, false, false, false)
    end
end)

RegisterNetEvent('pitrs_smenarnik:playSuccessAnim')
AddEventHandler('pitrs_smenarnik:playSuccessAnim', function()
    if npc and DoesEntityExist(npc) then
        lib.requestAnimDict('gestures@m@standing@fat')
        TaskPlayAnim(npc, 'gestures@m@standing@fat', 'gesture_bye_soft', 8.0, -8.0, 2000, 0, 0, false, false, false)
    end
end)