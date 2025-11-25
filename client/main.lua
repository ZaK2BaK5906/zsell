local spawnedPeds = {}
local currentNegotiation = nil
local busyPeds = {}

-- Fonction pour obtenir la traduction
local function L(key)
    return Locales[Config.Locale][key] or key
end

-- Fonction pour afficher une notification
local function Notify(message, type)
    lib.notify({
        title = 'Vente de drogue',
        description = message,
        type = type or 'info'
    })
end

-- Fonction pour créer un PNJ
local function CreateDealerPed(location)
    local model = Config.PedModels[math.random(#Config.PedModels)]
    lib.requestModel(model, 10000)

    local ped = CreatePed(4, model, location.coords.x, location.coords.y, location.coords.z, location.coords.w, false, true)
    SetEntityAsMissionEntity(ped, true, true)
    SetPedFleeAttributes(ped, 0, 0)
    SetPedDiesWhenInjured(ped, false)
    SetPedKeepTask(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    -- Appliquer le scénario
    if location.scenario then
        TaskStartScenarioInPlace(ped, location.scenario, 0, true)
    end

    -- Ajouter l'option ox_target
    exports.ox_target:addLocalEntity(ped, {
        {
            name = 'sell_drugs',
            icon = 'fas fa-cannabis',
            label = L('target_sell_drugs'),
            onSelect = function()
                if busyPeds[ped] then
                    Notify(L('ped_busy'), 'error')
                    return
                end
                OpenDrugSelectionUI(ped)
            end,
            distance = Config.InteractionDistance
        }
    })

    return ped
end

-- Fonction pour spawn tous les PNJ
local function SpawnAllPeds()
    for _, location in ipairs(Config.PedLocations) do
        local ped = CreateDealerPed(location)
        table.insert(spawnedPeds, {
            ped = ped,
            location = location
        })
    end

    if Config.Debug then
        print(('[DEBUG] %d PNJs de dealers ont été spawn'):format(#spawnedPeds))
    end
end

-- Fonction pour obtenir les drogues que le joueur possède
local function GetPlayerDrugs()
    local drugs = {}

    for _, drugConfig in ipairs(Config.Drugs) do
        local count = exports.ox_inventory:Search('count', drugConfig.item)
        if count > 0 then
            table.insert(drugs, {
                item = drugConfig.item,
                label = drugConfig.label,
                count = count,
                minPrice = drugConfig.minPrice,
                maxPrice = drugConfig.maxPrice
            })
        end
    end

    return drugs
end

-- Fonction pour ouvrir l'UI de sélection de drogue
function OpenDrugSelectionUI(ped)
    local playerDrugs = GetPlayerDrugs()

    if #playerDrugs == 0 then
        Notify(L('no_drugs'), 'error')
        return
    end

    -- Marquer le PNJ comme occupé
    busyPeds[ped] = true

    -- Ouvrir le NUI
    SendNUIMessage({
        type = 'openUI',
        drugs = playerDrugs,
        locale = Config.Locale,
        translations = {
            title = L('ui_title'),
            subtitle = L('ui_subtitle'),
            select = L('ui_select'),
            quantity = L('ui_quantity'),
            price = L('ui_price'),
            total = L('ui_total')
        }
    })

    SetNuiFocus(true, true)

    -- Stocker le PNJ actuel
    currentNegotiation = {
        ped = ped,
        started = false
    }
end

-- Fonction pour démarrer la négociation
local function StartNegotiation(selectedDrug, requestedPrice, quantity)
    if not currentNegotiation or not DoesEntityExist(currentNegotiation.ped) then
        Notify(L('too_far'), 'error')
        busyPeds[currentNegotiation.ped] = nil
        currentNegotiation = nil
        return
    end

    local playerPed = PlayerPedId()
    local ped = currentNegotiation.ped

    -- Vérifier la distance
    local pedCoords = GetEntityCoords(ped)
    local playerCoords = GetEntityCoords(playerPed)
    if #(pedCoords - playerCoords) > Config.InteractionDistance + 5.0 then
        Notify(L('too_far'), 'error')
        busyPeds[ped] = nil
        currentNegotiation = nil
        return
    end

    -- Faire regarder le PNJ vers le joueur
    TaskTurnPedToFaceEntity(ped, playerPed, 1000)
    Wait(500)

    -- Afficher un dialogue aléatoire
    local greetings = Config.NPCDialogues.greeting
    local greeting = L(greetings[math.random(#greetings)])

    lib.notify({
        title = 'Client',
        description = greeting,
        type = 'info',
        duration = 3000
    })

    Wait(2000)

    -- Le PNJ montre son intérêt
    local interested = Config.NPCDialogues.interested
    local interestedMsg = L(interested[math.random(#interested)])

    lib.notify({
        title = 'Client',
        description = interestedMsg,
        type = 'info',
        duration = 3000
    })

    -- Envoyer au serveur pour traiter la vente
    lib.callback('zsell:processSale', false, function(result)
        if result.success then
            if result.action == 'accept' then
                -- Animation de deal
                local dict = Config.Animations.deal.dict
                local anim = Config.Animations.deal.anim

                lib.requestAnimDict(dict, 1000)

                TaskPlayAnim(playerPed, dict, anim, 8.0, -8.0, Config.Animations.deal.duration, 0, 0, false, false, false)
                TaskPlayAnim(ped, dict, anim, 8.0, -8.0, Config.Animations.deal.duration, 0, 0, false, false, false)

                Wait(Config.Animations.deal.duration)

                -- Message d'acceptation
                local acceptMsgs = Config.NPCDialogues.accept
                local acceptMsg = L(acceptMsgs[math.random(#acceptMsgs)])

                lib.notify({
                    title = 'Client',
                    description = acceptMsg,
                    type = 'success',
                    duration = 3000
                })

                Notify(L('sale_success'):format(result.finalPrice * result.quantity), 'success')

            elseif result.action == 'refuse' then
                -- Message de refus
                local refuseMsgs = Config.NPCDialogues.refuse
                local refuseMsg = L(refuseMsgs[math.random(#refuseMsgs)])

                lib.notify({
                    title = 'Client',
                    description = refuseMsg,
                    type = 'error',
                    duration = 3000
                })

                Notify(L('sale_refused'), 'error')

            elseif result.action == 'steal' then
                -- Animation de vol
                local dict = Config.Animations.steal.dict
                local anim = Config.Animations.steal.anim

                lib.requestAnimDict(dict, 1000)
                TaskPlayAnim(ped, dict, anim, 8.0, -8.0, Config.Animations.steal.duration, 0, 0, false, false, false)

                Wait(500)

                -- Faire ragdoll le joueur
                SetPedToRagdoll(playerPed, 3000, 3000, 0, 0, 0, 0)

                Wait(1000)

                -- Message de vol
                local stealMsgs = Config.NPCDialogues.steal
                local stealMsg = L(stealMsgs[math.random(#stealMsgs)])

                lib.notify({
                    title = 'Client',
                    description = stealMsg,
                    type = 'error',
                    duration = 3000
                })

                Notify(L('got_stolen'), 'error')

                -- Le PNJ s'enfuit
                TaskSmartFleePed(ped, playerPed, 100.0, -1, false, false)

                -- Supprimer le PNJ après un délai
                SetTimeout(10000, function()
                    if DoesEntityExist(ped) then
                        DeleteEntity(ped)
                    end
                end)

            elseif result.action == 'callCops' then
                -- Message d'appel de police
                local copMsgs = Config.NPCDialogues.callCops
                local copMsg = L(copMsgs[math.random(#copMsgs)])

                lib.notify({
                    title = 'Client',
                    description = copMsg,
                    type = 'error',
                    duration = 5000
                })

                Notify(L('cops_called'), 'error')

                -- TODO: Ajouter l'appel à votre système de police ici
                -- TriggerServerEvent('police:alert', coords, 'Drug dealing')

                -- Le PNJ appelle la police (animation téléphone)
                TaskStartScenarioInPlace(ped, "WORLD_HUMAN_MOBILE_FILM_SHOCKING", 0, true)
            end
        else
            Notify(result.message or 'Erreur', 'error')
        end

        -- Libérer le PNJ
        SetTimeout(5000, function()
            busyPeds[ped] = nil
        end)

        currentNegotiation = nil
    end, selectedDrug, requestedPrice, quantity, NetworkGetNetworkIdFromEntity(ped))
end

-- NUI Callbacks
RegisterNUICallback('closeUI', function(data, cb)
    SetNuiFocus(false, false)

    -- Libérer le PNJ si la négociation n'a pas commencé
    if currentNegotiation and not currentNegotiation.started then
        busyPeds[currentNegotiation.ped] = nil
        currentNegotiation = nil
    end

    cb('ok')
end)

RegisterNUICallback('startNegotiation', function(data, cb)
    SetNuiFocus(false, false)

    if currentNegotiation then
        currentNegotiation.started = true
    end

    StartNegotiation(data.drug, data.price, data.quantity)

    cb('ok')
end)

-- Event pour respawn un PNJ
RegisterNetEvent('zsell:respawnPed', function(netId)
    local ped = NetworkGetEntityFromNetworkId(netId)

    if DoesEntityExist(ped) then
        -- Trouver la location du PNJ
        for i, spawnedPed in ipairs(spawnedPeds) do
            if spawnedPed.ped == ped then
                -- Supprimer le PNJ actuel
                DeleteEntity(ped)

                -- Respawn après le délai configuré
                SetTimeout(Config.PedRespawnTime * 1000, function()
                    local newPed = CreateDealerPed(spawnedPed.location)
                    spawnedPeds[i].ped = newPed
                end)

                break
            end
        end
    end
end)

-- Cleanup à la déconnexion
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    for _, spawnedPed in ipairs(spawnedPeds) do
        if DoesEntityExist(spawnedPed.ped) then
            DeleteEntity(spawnedPed.ped)
        end
    end
end)

-- Init
CreateThread(function()
    SpawnAllPeds()
end)
