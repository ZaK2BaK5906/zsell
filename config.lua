Config = {}

-- Langue du script (fr ou de)
Config.Locale = 'fr'

-- Mode debug (pas d'alerte police, logs activés)
Config.Debug = true

-- Distance d'interaction avec les PNJ
Config.InteractionDistance = 2.5

-- Distance de spawn des PNJ
Config.PedSpawnDistance = 100.0

-- Temps de respawn d'un PNJ après une vente (en secondes)
Config.PedRespawnTime = 300 -- 5 minutes

-- Configuration des drogues vendables
Config.Drugs = {
    {
        item = 'pochon_weed',
        label = 'Weed',
        minPrice = 200,
        maxPrice = 500,
        -- Chance de vente en fonction du prix (pourcentage du prix max)
        -- Si le joueur demande 80% du prix max, il a 40% de chance de vendre
        -- Si le joueur demande 100% du prix max, il a 10% de chance de vendre
        sellChance = {
            [40] = 90,  -- 40% du prix max = 90% de chance
            [60] = 70,  -- 60% du prix max = 70% de chance
            [80] = 40,  -- 80% du prix max = 40% de chance
            [100] = 10  -- 100% du prix max = 10% de chance
        }
    },
    {
        item = 'pochon_cocaine',
        label = 'Cocaine',
        minPrice = 400,
        maxPrice = 800,
        sellChance = {
            [40] = 90,
            [60] = 70,
            [80] = 40,
            [100] = 10
        }
    },
    {
        item = 'pochon_meth',
        label = 'Meth',
        minPrice = 350,
        maxPrice = 700,
        sellChance = {
            [40] = 90,
            [60] = 70,
            [80] = 40,
            [100] = 10
        }
    }
}

-- Chances des différents comportements du PNJ (en %)
Config.NPCBehavior = {
    accept = 50,    -- 50% chance d'accepter
    refuse = 30,    -- 30% chance de refuser
    steal = 15,     -- 15% chance de voler
    callCops = 5    -- 5% chance d'appeler les flics (désactivé en debug)
}

-- Quantité que le PNJ veut acheter (min-max)
Config.BuyQuantity = {
    min = 1,
    max = 5
}

-- Modèles de PNJ possibles
Config.PedModels = {
    'a_m_m_skater_01',
    'a_m_y_hipster_01',
    'a_m_y_hipster_02',
    'a_f_y_hipster_01',
    'a_m_m_beach_01',
    'a_m_y_beach_01',
    'a_f_y_beach_01',
    'a_m_m_hasjew_01',
    'a_m_y_downtown_01',
    'a_f_y_tourist_01'
}

-- Lieux de spawn des PNJ dealers
Config.PedLocations = {
    -- Groove Street
    {coords = vector4(127.22, -1930.24, 20.38, 320.0), scenario = 'WORLD_HUMAN_SMOKING'},
    {coords = vector4(183.17, -1832.84, 27.44, 240.0), scenario = 'WORLD_HUMAN_SMOKING'},
    {coords = vector4(246.39, -1730.51, 29.67, 140.0), scenario = 'WORLD_HUMAN_DRUG_DEALER_HARD'},

    -- Legion Square
    {coords = vector4(213.97, -822.13, 30.73, 160.0), scenario = 'WORLD_HUMAN_SMOKING'},
    {coords = vector4(301.28, -582.45, 43.28, 70.0), scenario = 'WORLD_HUMAN_DRUG_DEALER'},

    -- Vespucci Beach
    {coords = vector4(-1108.87, -1527.51, 4.63, 210.0), scenario = 'WORLD_HUMAN_SMOKING_POT'},
    {coords = vector4(-1289.23, -1384.32, 4.38, 110.0), scenario = 'WORLD_HUMAN_SMOKING'},

    -- Sandy Shores
    {coords = vector4(1961.98, 3743.88, 32.22, 300.0), scenario = 'WORLD_HUMAN_DRUG_DEALER_HARD'},
    {coords = vector4(1905.27, 3823.87, 32.98, 200.0), scenario = 'WORLD_HUMAN_SMOKING'},

    -- Paleto Bay
    {coords = vector4(-112.51, 6468.19, 31.63, 130.0), scenario = 'WORLD_HUMAN_SMOKING'},
    {coords = vector4(58.91, 6402.38, 31.48, 70.0), scenario = 'WORLD_HUMAN_DRUG_DEALER'},

    -- Mirror Park
    {coords = vector4(1138.29, -982.71, 46.42, 280.0), scenario = 'WORLD_HUMAN_SMOKING_POT'},
    {coords = vector4(1237.84, -896.32, 69.42, 10.0), scenario = 'WORLD_HUMAN_DRUG_DEALER'},

    -- Vinewood
    {coords = vector4(342.73, 437.99, 147.70, 290.0), scenario = 'WORLD_HUMAN_SMOKING'},
    {coords = vector4(1201.48, -424.62, 67.99, 75.0), scenario = 'WORLD_HUMAN_DRUG_DEALER_HARD'},
}

-- Animations
Config.Animations = {
    deal = {
        dict = 'mp_common',
        anim = 'givetake1_a',
        duration = 3000
    },
    steal = {
        dict = 'melee@unarmed@streamed_variations',
        anim = 'plyr_takedown_front_slap',
        duration = 1500
    }
}

-- Phrases de dialogue pour négociation (aléatoires)
Config.NPCDialogues = {
    greeting = {
        'npc_greeting_1',
        'npc_greeting_2',
        'npc_greeting_3',
        'npc_greeting_4'
    },
    interested = {
        'npc_interested_1',
        'npc_interested_2',
        'npc_interested_3'
    },
    negotiate = {
        'npc_negotiate_1',
        'npc_negotiate_2',
        'npc_negotiate_3'
    },
    accept = {
        'npc_accept_1',
        'npc_accept_2',
        'npc_accept_3'
    },
    refuse = {
        'npc_refuse_1',
        'npc_refuse_2',
        'npc_refuse_3'
    },
    steal = {
        'npc_steal_1',
        'npc_steal_2'
    },
    callCops = {
        'npc_callcops_1',
        'npc_callcops_2'
    }
}
