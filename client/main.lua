local addedPeds = {}
local currentNegotiation = nil
local busyPeds = {}
local pedCooldowns = {} -- Track des PNJ en cooldown avec timestamp

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

-- Fonction pour vérifier si un PNJ est en cooldown
local function IsPedOnCooldown(ped)
    if pedCooldowns[ped] then
        local timeLeft = pedCooldowns[ped] - GetGameTimer()
        if timeLeft > 0 then
            -- Calculer le temps restant en minutes et secondes
            local minutes = math.floor(timeLeft / 60000)
            local seconds = math.floor((timeLeft % 60000) / 1000)

            if Config.Debug then
                print(('[DEBUG] PNJ en cooldown: %dm %ds restantes'):format(minutes, seconds))
            end

            Notify(('Ce client a besoin de temps. Revenez dans %dm %ds'):format(minutes, seconds), 'error')
            return true
        else
            -- Cooldown expiré, retirer du tableau
            pedCooldowns[ped] = nil
            return false
        end
    end
    return false
end

-- Fonction pour mettre un PNJ en cooldown
local function SetPedCooldown(ped)
    pedCooldowns[ped] = GetGameTimer() + (Config.PedCooldown * 1000)

    if Config.Debug then
        print(('[DEBUG] PNJ mis en cooldown pour %d secondes'):format(Config.PedCooldown))
    end
end

-- Fonction pour vérifier si le joueur est dans une zone de vente autorisée
local function IsPlayerInSalesZone()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    for _, zone in ipairs(Config.SalesZones) do
        local distance = #(playerCoords - zone.coords)
        if distance <= zone.radius then
            if Config.Debug then
                print(('[DEBUG] Joueur dans la zone de vente: %s (distance: %.2fm)'):format(zone.name, distance))
            end
            return true, zone.name
        end
    end

    if Config.Debug then
        print('[DEBUG] Joueur hors de toutes les zones de vente')
    end

    return false, nil
end

-- Validation du PNJ (comme dans le code de référence)
function IsValidPed(ped)
    if not DoesEntityExist(ped) or IsPedAPlayer(ped) then return false end
    if IsPedDeadOrDying(ped, true) or IsPedInAnyVehicle(ped, true) then return false end
    if IsPedSwimming(ped) or IsPedInCombat(ped, 0) or IsPedFleeing(ped) then return false end
    if IsPedStill(ped) or IsPedUsingAnyScenario(ped) then return false end
    if not IsPedHuman(ped) then return false end
    -- Vérifier que le ped n'est pas un joueur réel (double check)
    local players = GetActivePlayers()
    for _, player in ipairs(players) do
        if GetPlayerPed(player) == ped then
            return false
        end
    end
    return true
end

-- Animation de conversation pour le PNJ
function PlayConversationAnimationForPNJ(ped)
    RequestAnimDict("amb@world_human_stand_mobile@male@text@base")
    RequestAnimDict("facials@gen_male@variations@normal")
    while not HasAnimDictLoaded("amb@world_human_stand_mobile@male@text@base") or not HasAnimDictLoaded("facials@gen_male@variations@normal") do
        Wait(100)
    end
    TaskPlayAnim(ped, "amb@world_human_stand_mobile@male@text@base", "base", 8.0, -8.0, -1, 1, 0, false, false, false)
    TaskPlayAnim(ped, "facials@gen_male@variations@normal", "facmood_neutral_loop", 8.0, -8.0, -1, 1, 0, false, false, false)

    -- Freezer le PNJ pour toute la durée de l'interaction
    FreezeEntityPosition(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
end

-- Fonction pour libérer le PNJ
function ReleasePed(ped)
    if DoesEntityExist(ped) then
        ClearPedTasks(ped)
        FreezeEntityPosition(ped, false)
        SetBlockingOfNonTemporaryEvents(ped, false)
    end
end

-- Scanner tous les PNJ et ajouter le target (comme dans le code de référence)
CreateThread(function()
    while true do
        Wait(5000)

        -- Nettoyer les peds qui n'existent plus
        for pedId, _ in pairs(addedPeds) do
            if not DoesEntityExist(pedId) or not IsValidPed(pedId) then
                addedPeds[pedId] = nil
                busyPeds[pedId] = nil
                pedCooldowns[pedId] = nil

                if Config.Debug then
                    print(('[DEBUG] Nettoyage du PNJ (ID: %d) - n\'existe plus ou invalide'):format(pedId))
                end
            end
        end

        local peds = GetGamePool('CPed')
        for _, ped in pairs(peds) do
            -- Vérifier que le ped est valide ET qu'il n'a pas déjà le target
            if not addedPeds[ped] and IsValidPed(ped) then
                -- Sécurité supplémentaire : vérifier que l'entité existe toujours
                if DoesEntityExist(ped) then
                    exports.ox_target:addLocalEntity(ped, {
                        {
                            name = 'sell_drugs',
                            icon = 'fas fa-cannabis',
                            label = L('target_sell_drugs'),
                            distance = 2.5,
                            onSelect = function(data)
                                -- Vérifier que le ped existe encore au moment du clic
                                if not DoesEntityExist(ped) or not IsValidPed(ped) then
                                    Notify('Ce PNJ n\'est plus disponible', 'error')
                                    return
                                end

                                if busyPeds[ped] then
                                    Notify(L('ped_busy'), 'error')
                                    return
                                end

                                -- Vérifier si le PNJ est en cooldown
                                if IsPedOnCooldown(ped) then
                                    return
                                end

                                -- Vérifier si le joueur est dans une zone de vente autorisée
                                local inZone, zoneName = IsPlayerInSalesZone()
                                if not inZone then
                                    -- Le PNJ refuse immédiatement car pas dans une zone de vente
                                    local playerPed = PlayerPedId()
                                    TaskTurnPedToFaceEntity(ped, playerPed, 1000)
                                    Wait(500)

                                    lib.notify({
                                        title = 'Client',
                                        description = L('npc_outside_zone'),
                                        type = 'error',
                                        duration = 4000
                                    })

                                    Notify(L('outside_zone'), 'error')
                                    return
                                end

                                PlayConversationAnimationForPNJ(ped)
                                OpenDrugSelectionUI(ped)
                            end
                        }
                    }, {
                        distance = 3.0,
                        bone = nil,
                        size = vec3(1.5, 1.5, 2.0)
                    })
                    addedPeds[ped] = true

                    if Config.Debug then
                        local coords = GetEntityCoords(ped)
                        print(('[DEBUG] Target ajouté au PNJ (ID: %d) à %.2f, %.2f, %.2f'):format(ped, coords.x, coords.y, coords.z))
                    end
                end
            end
        end
    end
end)

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
        if currentNegotiation then
            busyPeds[currentNegotiation.ped] = nil
        end
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

                -- Libérer le PNJ et mettre en cooldown
                ReleasePed(ped)
                busyPeds[ped] = nil
                SetPedCooldown(ped)

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

                -- Libérer le PNJ et mettre en cooldown
                ReleasePed(ped)
                busyPeds[ped] = nil
                SetPedCooldown(ped)

            elseif result.action == 'steal' then
                -- IMPORTANT: Libérer le PNJ AVANT qu'il vole pour qu'il puisse courir
                ReleasePed(ped)
                busyPeds[ped] = nil
                SetPedCooldown(ped)

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
                ClearPedTasks(ped)
                TaskSmartFleePed(ped, playerPed, 100.0, -1, false, false)

            elseif result.action == 'callCops' then
                -- IMPORTANT: Libérer le PNJ AVANT qu'il appelle pour qu'il puisse bouger
                ReleasePed(ped)
                busyPeds[ped] = nil
                SetPedCooldown(ped)

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

                -- Envoyer l'alerte à la police
                local playerCoords = GetEntityCoords(playerPed)
                TriggerServerEvent('zsell:sendPoliceAlert', playerCoords)

                -- Le PNJ appelle la police (animation téléphone)
                TaskStartScenarioInPlace(ped, "WORLD_HUMAN_MOBILE_FILM_SHOCKING", 0, true)
            end
        else
            Notify(result.message or 'Erreur', 'error')
            -- Libérer le PNJ en cas d'erreur
            ReleasePed(ped)
            busyPeds[ped] = nil
        end

        currentNegotiation = nil
    end, selectedDrug, requestedPrice, quantity)
end

-- NUI Callbacks
RegisterNUICallback('closeUI', function(data, cb)
    SetNuiFocus(false, false)

    -- Libérer le PNJ si la négociation n'a pas commencé
    if currentNegotiation and not currentNegotiation.started then
        busyPeds[currentNegotiation.ped] = nil
        ReleasePed(currentNegotiation.ped)
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

-- Cleanup à la déconnexion
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    -- Vider les tables
    addedPeds = {}
    busyPeds = {}
    pedCooldowns = {}
    currentNegotiation = nil

    if Config.Debug then
        print('[DEBUG] Cleanup effectué')
    end
end)

-- Message de démarrage
if Config.Debug then
    print('^2[Z-SELL]^7 Script de vente de drogue chargé')
    print('^3[Z-SELL]^7 Scanner des PNJ actif (check toutes les 5 secondes)')
    print('^3[Z-SELL]^7 Approchez-vous de n\'importe quel PNJ pour vendre')
end
