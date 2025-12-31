-- Système de notification pour la police
local policeAlertActive = false
local currentBlip = nil
local currentRoute = nil

-- Fonction pour vérifier si le joueur est policier
local function IsPlayerPolice()
    -- IMPORTANT: Adaptez cette fonction selon votre framework
    -- ESX:
    -- local PlayerData = ESX.GetPlayerData()
    -- return PlayerData.job and PlayerData.job.name == 'police'

    -- QBCore:
    -- local PlayerData = QBCore.Functions.GetPlayerData()
    -- return PlayerData.job and PlayerData.job.name == 'police'

    -- OX_CORE:
    -- local player = Ox.GetPlayer()
    -- return player.getGroup() == 'police'

    -- Pour test (retourne toujours true)
    if Config.Debug then
        return true
    end

    return false -- Changez ça selon votre framework
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

    if Config.Debug then
        print('[DEBUG] Blip créé aux coordonnées:', coords.x, coords.y, coords.z)
    end

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

    if Config.Debug then
        print('[DEBUG] Route GPS définie vers:', coords.x, coords.y)
    end
end

-- Event pour recevoir une alerte de police
RegisterNetEvent('zsell:policeAlert', function(data)
    -- Vérifier si le joueur est policier
    if not IsPlayerPolice() then
        return
    end

    if policeAlertActive then
        if Config.Debug then
            print('[DEBUG] Une alerte est déjà active, ignorée')
        end
        return
    end

    policeAlertActive = true

    -- Obtenir le nom de la rue et de la zone
    local streetName = GetStreetName(data.coords)
    local zoneName = GetZoneName(data.coords)
    local location = streetName .. ", " .. zoneName

    if Config.Debug then
        print('[DEBUG] Alerte de police reçue:', location)
    end

    -- Jouer le son d'alerte
    SendNUIMessage({
        type = 'playSound',
        sound = 'police_alert'
    })

    -- Afficher la notification UI
    SendNUIMessage({
        type = 'showPoliceAlert',
        location = location,
        time = 'Il y a quelques instants',
        coords = data.coords
    })

    -- Notification ox_lib en backup
    lib.notify({
        title = '🚨 APPEL D\'URGENCE',
        description = 'Vente de drogue signalée à ' .. location,
        type = 'error',
        duration = 5000,
        position = 'top'
    })
end)

-- NUI Callback pour accepter l'alerte
RegisterNUICallback('acceptPoliceAlert', function(data, cb)
    if Config.Debug then
        print('[DEBUG] Alerte acceptée par le policier')
    end

    -- Créer le blip et la route GPS
    local radiusBlip = CreatePoliceBlip(data.coords)
    SetGPSRoute(data.coords)

    -- Notification de confirmation
    lib.notify({
        title = '✅ Intervention acceptée',
        description = 'Route GPS activée vers la position',
        type = 'success',
        duration = 3000
    })

    policeAlertActive = false
    cb('ok')
end)

-- NUI Callback pour refuser l'alerte
RegisterNUICallback('declinePoliceAlert', function(data, cb)
    if Config.Debug then
        print('[DEBUG] Alerte refusée par le policier')
    end

    -- Notification de refus
    lib.notify({
        title = 'ℹ️ Intervention refusée',
        description = 'L\'alerte a été ignorée',
        type = 'inform',
        duration = 2000
    })

    policeAlertActive = false
    cb('ok')
end)

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

if Config.Debug then
    print('^2[Z-SELL]^7 Module police chargé')
    print('^3[Z-SELL]^7 Les policiers recevront des alertes personnalisées')
end
