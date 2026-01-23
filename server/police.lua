-- Système de dispatch pour la police
ESX = exports['es_extended']:getSharedObject()

-- Fonction pour obtenir tous les joueurs avec le job police ou sheriff
local function GetPoliceOfficers()
    local officers = {}

    -- ESX activé - Police
    local xPolice = ESX.GetExtendedPlayers('job', 'police')
    for _, xPlayer in pairs(xPolice) do
        table.insert(officers, xPlayer.source)
    end

    -- ESX activé - Sheriff
    local xSheriff = ESX.GetExtendedPlayers('job', 'sheriff')
    for _, xPlayer in pairs(xSheriff) do
        table.insert(officers, xPlayer.source)
    end

    return officers
end

-- Event pour envoyer une alerte de police
RegisterNetEvent('zsell:sendPoliceAlert', function(coords)
    local src = source

    if not coords then
        return
    end

    -- Obtenir tous les policiers
    local officers = GetPoliceOfficers()

    if #officers == 0 then
        return
    end

    -- Envoyer l'alerte à tous les policiers
    for _, officerId in pairs(officers) do
        TriggerClientEvent('zsell:policeAlert', officerId, {
            coords = coords,
            reporterId = src
        })
    end
end)
