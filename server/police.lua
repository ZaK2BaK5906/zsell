-- Système de dispatch pour la police

-- Fonction pour obtenir tous les joueurs avec le job police
local function GetPoliceOfficers()
    local officers = {}

    -- IMPORTANT: Adaptez selon votre framework

    -- ESX:
    --[[
    local xPlayers = ESX.GetExtendedPlayers('job', 'police')
    for _, xPlayer in pairs(xPlayers) do
        table.insert(officers, xPlayer.source)
    end
    ]]

    -- QBCore:
    --[[
    local Players = QBCore.Functions.GetPlayers()
    for _, playerId in pairs(Players) do
        local Player = QBCore.Functions.GetPlayer(playerId)
        if Player and Player.PlayerData.job.name == 'police' then
            table.insert(officers, playerId)
        end
    end
    ]]

    -- OX_CORE:
    --[[
    local players = Ox.GetPlayers()
    for _, playerId in pairs(players) do
        local player = Ox.GetPlayer(playerId)
        if player and player.getGroup() == 'police' then
            table.insert(officers, playerId)
        end
    end
    ]]

    -- Pour test (envoyer à tous les joueurs en mode debug)
    if Config.Debug then
        local allPlayers = GetPlayers()
        for _, playerId in pairs(allPlayers) do
            table.insert(officers, tonumber(playerId))
        end
    end

    return officers
end

-- Event pour envoyer une alerte de police
RegisterNetEvent('zsell:sendPoliceAlert', function(coords)
    local src = source

    print('^3[Z-SELL SERVER]^7 Event reçu: zsell:sendPoliceAlert depuis joueur #' .. src)

    if not coords then
        print('[Z-SELL] ^1ERREUR: Coordonnées manquantes pour l\'alerte police^7')
        return
    end

    print(('[Z-SELL SERVER] Position: %.2f, %.2f, %.2f'):format(coords.x, coords.y, coords.z))

    -- Obtenir tous les policiers
    local officers = GetPoliceOfficers()

    print(('[Z-SELL SERVER] Nombre de policiers trouvés: %d'):format(#officers))

    if #officers == 0 then
        print('^1[Z-SELL SERVER] Aucun policier en service pour recevoir l\'alerte^7')
        return
    end

    -- Envoyer l'alerte à tous les policiers
    for _, officerId in pairs(officers) do
        print(('^3[Z-SELL SERVER]^7 Envoi alerte au policier #%d'):format(officerId))
        TriggerClientEvent('zsell:policeAlert', officerId, {
            coords = coords,
            reporterId = src
        })
    end

    print('^2[Z-SELL SERVER]^7 ✅ Alerte de police envoyée avec succès')
end)

if Config.Debug then
    print('^2[Z-SELL]^7 Module de dispatch police chargé')
end
