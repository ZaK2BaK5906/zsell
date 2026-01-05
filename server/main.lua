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

    return chance
end

-- Fonction pour déterminer l'action du PNJ
local function DetermineNPCAction(sellChance)
    local roll = math.random(100)

    -- Système de détermination de l'action
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

    -- Vérifier que le prix est dans la fourchette autorisée
    if requestedPrice < drugConfig.minPrice or requestedPrice > drugConfig.maxPrice then
        return {
            success = false,
            message = 'Prix invalide'
        }
    end

    -- Calculer la chance de vente
    local sellChance = GetSellChance(drugConfig, requestedPrice)

    -- Déterminer l'action du PNJ
    local action = DetermineNPCAction(sellChance)

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
            -- Ajouter l'argent sale
            local totalPrice = requestedPrice * wantedQuantity
            exports.ox_inventory:AddItem(src, 'black_money', totalPrice)

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
        return {
            success = true,
            action = 'refuse'
        }

    elseif action == 'steal' then
        -- Le PNJ vole la drogue
        local stolenQuantity = math.random(1, math.min(3, quantity))

        if count >= stolenQuantity then
            exports.ox_inventory:RemoveItem(src, drugItem, stolenQuantity)
        end

        return {
            success = true,
            action = 'steal',
            stolenQuantity = stolenQuantity
        }

    elseif action == 'callCops' then
        -- Le PNJ appelle les flics
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
