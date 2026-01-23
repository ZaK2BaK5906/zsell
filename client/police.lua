-- Système de notification pour la police
ESX = exports['es_extended']:getSharedObject()

local policeAlertActive = false
local currentBlip = nil
local currentRoute = nil

-- Fonction pour vérifier si le joueur est policier ou sheriff
local function IsPlayerPolice()
    -- ESX activé
    local PlayerData = ESX.GetPlayerData()
    return PlayerData.job and (PlayerData.job.name == 'police' or PlayerData.job.name == 'sheriff')
end

-- Fonction pour obtenir le nom de la rue
local function GetStreetName(coords)
    local streetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local streetName = GetStreetNameFromHashKey(streetHash)
    return streetName or "Position inconnue"
end

-- Fonction pour obtenir le nom de la zone
local function GetZoneName(coords)
    local zoneHash = GetNameOfZone(coords.x, coords.y, coords.z)
    local zoneName = GetLabelText(zoneHash)
    return zoneName or "Zone inconnue"
end

-- Fonction pour créer un blip sur la carte
local function CreatePoliceBlip(coords)
    -- Supprimer l'ancien blip si il existe
    if currentBlip then
        RemoveBlip(currentBlip)
    end

    -- Créer le nouveau blip
    currentBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(currentBlip, 161) -- Icône de dealer
    SetBlipColour(currentBlip, 1) -- Rouge
    SetBlipScale(currentBlip, 1.2)
    SetBlipAsShortRange(currentBlip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("🚨 Vente de drogue signalée")
    EndTextCommandSetBlipName(currentBlip)

    -- Faire clignoter le blip
    SetBlipFlashes(currentBlip, true)

    -- Ajouter un rayon autour du blip
    local radius = AddBlipForRadius(coords.x, coords.y, coords.z, 100.0)
    SetBlipColour(radius, 1)
    SetBlipAlpha(radius, 128)

    -- Supprimer automatiquement après 5 minutes
    SetTimeout(300000, function()
        if currentBlip then
            RemoveBlip(currentBlip)
            RemoveBlip(radius)
            currentBlip = nil
        end
    end)

    return radius
end

-- Fonction pour créer un waypoint GPS
local function SetGPSRoute(coords)
    -- Supprimer l'ancienne route
    if currentRoute then
        ClearGpsMultiRoute()
        currentRoute = nil
    end

    -- Créer la nouvelle route
    SetNewWaypoint(coords.x, coords.y)
    currentRoute = true
end

-- Event pour recevoir une alerte de police
RegisterNetEvent('zsell:policeAlert', function(data)
    -- Vérifier si le joueur est policier
    local isPolice = IsPlayerPolice()

    if not isPolice then
        return
    end

    if policeAlertActive then
        return
    end

    policeAlertActive = true

    -- Obtenir le nom de la rue et de la zone
    local streetName = GetStreetName(data.coords)
    local zoneName = GetZoneName(data.coords)
    local location = streetName .. ", " .. zoneName

    -- Jouer le son d'alerte
    SendNUIMessage({
        type = 'playSound',
        sound = 'police_alert'
    })

    -- Afficher la notification UI
    SendNUIMessage({
        type = 'showPoliceAlert',
        location = location,
        time = 'Il y a quelques instants'
    })

    -- CRÉER DIRECTEMENT LE GPS + BLIP (pas besoin d'accepter)
    CreatePoliceBlip(data.coords)
    SetGPSRoute(data.coords)

    -- Auto-reset après 5 secondes
    SetTimeout(5000, function()
        policeAlertActive = false
    end)
end)

-- Callbacks NUI supprimés (GPS créé automatiquement maintenant)

-- Cleanup à l'arrêt de la ressource
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    -- Nettoyer les blips
    if currentBlip then
        RemoveBlip(currentBlip)
    end

    -- Fermer l'UI
    SendNUIMessage({
        type = 'hidePoliceAlert'
    })

    policeAlertActive = false
end)
