-- Fonction pour obtenir la configuration d'une drogue
local function GetDrugConfig(itemName)
    for _, drug in ipairs(Config.Drugs) do
        if drug.item == itemName then
            return drug
        end
    end
    return nil
end

-- Fonction pour calculer la chance de vente basée sur le prix
local function GetSellChance(drugConfig, requestedPrice)
    local priceRange = drugConfig.maxPrice - drugConfig.minPrice
    local pricePercent = math.floor(((requestedPrice - drugConfig.minPrice) / priceRange) * 100)

    -- Trouver la chance correspondante
    local chance = 50 -- Chance par défaut

    for percent, chanceValue in pairs(drugConfig.sellChance) do
        if pricePercent <= percent then
            chance = chanceValue
            break
        end
    end

    if Config.Debug then
        print(('[DEBUG] Prix: %s$ (%d%% du max) = %d%% de chance'):format(requestedPrice, pricePercent, chance))
    end

    return chance
end

-- Fonction pour déterminer l'action du PNJ
local function DetermineNPCAction(sellChance)
    local roll = math.random(100)

    if Config.Debug then
        -- En mode debug, pas d'appel aux flics
        if roll <= sellChance then
            return 'accept'
        elseif roll <= (sellChance + Config.NPCBehavior.refuse) then
            return 'refuse'
        else
            return 'steal'
        end
    else
        -- Mode normal
        if roll <= sellChance then
            return 'accept'
        elseif roll <= (sellChance + Config.NPCBehavior.refuse) then
            return 'refuse'
        elseif roll <= (sellChance + Config.NPCBehavior.refuse + Config.NPCBehavior.steal) then
            return 'steal'
        else
            return 'callCops'
        end
    end
end

-- Callback pour traiter la vente
lib.callback.register('zsell:processSale', function(source, drugItem, requestedPrice, quantity, pedNetId)
    local src = source
    local drugConfig = GetDrugConfig(drugItem)

    if not drugConfig then
        return {
            success = false,
            message = 'Configuration de drogue invalide'
        }
    end

    -- Vérifier que le joueur a la drogue
    local count = exports.ox_inventory:Search(src, 'count', drugItem)
    if count < quantity then
        return {
            success = false,
            message = 'Vous n\'avez pas assez de drogue'
        }
    end

    -- Vérifier si le prix est abusif (> max * 2) -> le PNJ te met une claque et vole TOUT
    if requestedPrice > (drugConfig.maxPrice * 2) then
        if Config.Debug then
            print(('[DEBUG] Prix abusif détecté: %s$ (max: %s$) -> Vol automatique de TOUT'):format(requestedPrice, drugConfig.maxPrice))
        end

        -- Voler TOUTE la quantité demandée
        if count >= quantity then
            exports.ox_inventory:RemoveItem(src, drugItem, quantity)
        else
            exports.ox_inventory:RemoveItem(src, drugItem, count)
        end

        return {
            success = true,
            action = 'steal',
            stolenQuantity = math.min(quantity, count),
            abusivePrice = true
        }
    end

    -- Calculer la chance de vente
    local sellChance = GetSellChance(drugConfig, requestedPrice)

    -- Déterminer l'action du PNJ
    local action = DetermineNPCAction(sellChance)

    if Config.Debug then
        print(('[DEBUG] Action du PNJ: %s'):format(action))
    end

    if action == 'accept' then
        -- Le PNJ accepte
        -- Quantité que le PNJ veut acheter (peut être moins que ce que le joueur propose)
        local wantedQuantity = math.random(Config.BuyQuantity.min, math.min(Config.BuyQuantity.max, quantity))

        -- Vérifier à nouveau que le joueur a la quantité
        if count < wantedQuantity then
            wantedQuantity = count
        end

        -- Retirer la drogue
        local removed = exports.ox_inventory:RemoveItem(src, drugItem, wantedQuantity)

        if removed then
            -- Ajouter l'argent
            local totalPrice = requestedPrice * wantedQuantity
            exports.ox_inventory:AddItem(src, 'money', totalPrice)

            if Config.Debug then
                print(('[DEBUG] Vente réussie: %d x %s pour %s$'):format(wantedQuantity, drugItem, totalPrice))
            end

            return {
                success = true,
                action = 'accept',
                quantity = wantedQuantity,
                finalPrice = requestedPrice
            }
        else
            return {
                success = false,
                message = 'Erreur lors du retrait de la drogue'
            }
        end

    elseif action == 'refuse' then
        -- Le PNJ refuse
        if Config.Debug then
            print('[DEBUG] Le PNJ a refusé la vente')
        end

        return {
            success = true,
            action = 'refuse'
        }

    elseif action == 'steal' then
        -- Le PNJ vole la drogue
        local stolenQuantity = math.random(1, math.min(3, quantity))

        if count >= stolenQuantity then
            exports.ox_inventory:RemoveItem(src, drugItem, stolenQuantity)

            if Config.Debug then
                print(('[DEBUG] Le PNJ a volé %d x %s'):format(stolenQuantity, drugItem))
            end
        end

        return {
            success = true,
            action = 'steal',
            stolenQuantity = stolenQuantity
        }

    elseif action == 'callCops' then
        -- Le PNJ appelle les flics
        if Config.Debug then
            print('[DEBUG] Le PNJ voulait appeler les flics (désactivé en debug)')
        end

        -- TODO: Intégrer avec votre système de police
        -- local playerCoords = GetEntityCoords(GetPlayerPed(src))
        -- TriggerEvent('police:alert', playerCoords, 'Vente de drogue signalée')

        return {
            success = true,
            action = 'callCops'
        }
    end

    return {
        success = false,
        message = 'Erreur inconnue'
    }
end)

-- Logs en mode debug
if Config.Debug then
    print('^2[Z-SELL]^7 Script de vente de drogue chargé en mode DEBUG')
    print('^3[Z-SELL]^7 ' .. #Config.PedLocations .. ' emplacements de dealers configurés')
    print('^3[Z-SELL]^7 ' .. #Config.Drugs .. ' types de drogues configurés')
end
