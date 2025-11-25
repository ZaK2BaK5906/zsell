Config = {}

-- Langue du script (fr ou de)
Config.Locale = 'fr'

-- Mode debug (pas d'alerte police, logs activés)
Config.Debug = true

-- Distance d'interaction avec les PNJ
Config.InteractionDistance = 2.5

-- Cooldown entre deux ventes au même PNJ (en secondes)
Config.PedCooldown = 300 -- 5 minutes

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
