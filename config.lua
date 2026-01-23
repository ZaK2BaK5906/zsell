Config = {}

-- Langue du script (fr ou de)
Config.Locale = 'fr'

-- Mode debug (pas d'alerte police, logs activés)
Config.Debug = true

-- Distance d'interaction avec les PNJ
Config.InteractionDistance = 2.5

-- Cooldown entre deux ventes au même PNJ (en secondes)
Config.PedCooldown = 300 -- 5 minutes

-- Paramètres d'optimisation du scanner
Config.ScanDistance = 50.0 -- Distance de scan des PNJs (en mètres)
Config.CleanupDistance = 100.0 -- Distance pour supprimer les targets trop loin
Config.ScanInterval = 30000 -- Intervalle de scan (en ms) - 30 secondes
Config.MinMoveDistance = 20.0 -- Distance minimale de déplacement pour rescanner
Config.MaxPedsPerScan = 20 -- Nombre max de PNJs traités par scan

-- Zones de vente autorisées (hors de ces zones, les PNJ refusent automatiquement)
Config.SalesZones = {
    {
        name = 'Vespucci',
        coords = vector3(-1184.07, -1510.02, 4.38), -- Vespucci Beach
        radius = 500.0
    },
    {
        name = 'Mirror Park',
        coords = vector3(1201.85, -694.54, 60.51), -- Mirror Park
        radius = 400.0
    },
    {
        name = 'Vinewood',
        coords = vector3(374.36, 423.48, 145.68), -- Vinewood
        radius = 450.0
    },
    {
        name = 'Paleto Bay',
        coords = vector3(-378.84, 6062.02, 31.50), -- Paleto Bay
        radius = 400.0
    },
    {
        name = 'Sandy Shores',
        coords = vector3(1961.92, 3740.48, 32.34), -- Sandy Shores
        radius = 450.0
    },
    {
        name = 'Grapeseed',
        coords = vector3(1699.92, 4924.36, 42.06), -- Grapeseed
        radius = 350.0
    }
}

-- Configuration des drogues vendables
Config.Drugs = {
    -- ============================================
    -- DROGUES
    -- ============================================
    {
        item = 'pochon_weed',
        label = 'Weed',
        minPrice = 200,
        maxPrice = 500,
        sellChance = {
            [40] = 90,
            [60] = 70,
            [80] = 40,
            [100] = 10
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
    },

    -- ============================================
    -- BIÈRES
    -- ============================================
    {
        item = 'beer_low',
        label = 'Bière (Mauvaise qualité)',
        minPrice = 80,
        maxPrice = 150,
        sellChance = {
            [40] = 90,
            [60] = 70,
            [80] = 40,
            [100] = 10
        }
    },
    {
        item = 'beer_mid',
        label = 'Bière (Qualité moyenne)',
        minPrice = 180,
        maxPrice = 320,
        sellChance = {
            [40] = 90,
            [60] = 70,
            [80] = 40,
            [100] = 10
        }
    },
    {
        item = 'beer_high',
        label = 'Bière (Bonne qualité)',
        minPrice = 300,
        maxPrice = 520,
        sellChance = {
            [40] = 90,
            [60] = 70,
            [80] = 40,
            [100] = 10
        }
    },

    -- ============================================
    -- VODKA
    -- ============================================
    {
        item = 'vodka_low',
        label = 'Vodka (Mauvaise qualité)',
        minPrice = 100,
        maxPrice = 200,
        sellChance = {
            [40] = 90,
            [60] = 70,
            [80] = 40,
            [100] = 10
        }
    },
    {
        item = 'vodka_mid',
        label = 'Vodka (Qualité moyenne)',
        minPrice = 220,
        maxPrice = 380,
        sellChance = {
            [40] = 90,
            [60] = 70,
            [80] = 40,
            [100] = 10
        }
    },
    {
        item = 'vodka_high',
        label = 'Vodka (Bonne qualité)',
        minPrice = 370,
        maxPrice = 620,
        sellChance = {
            [40] = 90,
            [60] = 70,
            [80] = 40,
            [100] = 10
        }
    },

    -- ============================================
    -- WHISKY
    -- ============================================
    {
        item = 'whisky_low',
        label = 'Whisky (Mauvaise qualité)',
        minPrice = 140,
        maxPrice = 260,
        sellChance = {
            [40] = 90,
            [60] = 70,
            [80] = 40,
            [100] = 10
        }
    },
    {
        item = 'whisky_mid',
        label = 'Whisky (Qualité moyenne)',
        minPrice = 290,
        maxPrice = 510,
        sellChance = {
            [40] = 90,
            [60] = 70,
            [80] = 40,
            [100] = 10
        }
    },
    {
        item = 'whisky_high',
        label = 'Whisky (Bonne qualité)',
        minPrice = 480,
        maxPrice = 800,
        sellChance = {
            [40] = 90,
            [60] = 70,
            [80] = 40,
            [100] = 10
        }
    },

    -- ============================================
    -- RHUM
    -- ============================================
    {
        item = 'rhum_low',
        label = 'Rhum (Mauvaise qualité)',
        minPrice = 120,
        maxPrice = 240,
        sellChance = {
            [40] = 90,
            [60] = 70,
            [80] = 40,
            [100] = 10
        }
    },
    {
        item = 'rhum_mid',
        label = 'Rhum (Qualité moyenne)',
        minPrice = 250,
        maxPrice = 450,
        sellChance = {
            [40] = 90,
            [60] = 70,
            [80] = 40,
            [100] = 10
        }
    },
    {
        item = 'rhum_high',
        label = 'Rhum (Bonne qualité)',
        minPrice = 400,
        maxPrice = 680,
        sellChance = {
            [40] = 90,
            [60] = 70,
            [80] = 40,
            [100] = 10
        }
    },

    -- ============================================
    -- GIN
    -- ============================================
    {
        item = 'gin_low',
        label = 'Gin (Mauvaise qualité)',
        minPrice = 120,
        maxPrice = 230,
        sellChance = {
            [40] = 90,
            [60] = 70,
            [80] = 40,
            [100] = 10
        }
    },
    {
        item = 'gin_mid',
        label = 'Gin (Qualité moyenne)',
        minPrice = 230,
        maxPrice = 410,
        sellChance = {
            [40] = 90,
            [60] = 70,
            [80] = 40,
            [100] = 10
        }
    },
    {
        item = 'gin_high',
        label = 'Gin (Bonne qualité)',
        minPrice = 380,
        maxPrice = 640,
        sellChance = {
            [40] = 90,
            [60] = 70,
            [80] = 40,
            [100] = 10
        }
    },

    -- ============================================
    -- TEQUILA
    -- ============================================
    {
        item = 'tequila_low',
        label = 'Tequila (Mauvaise qualité)',
        minPrice = 130,
        maxPrice = 250,
        sellChance = {
            [40] = 90,
            [60] = 70,
            [80] = 40,
            [100] = 10
        }
    },
    {
        item = 'tequila_mid',
        label = 'Tequila (Qualité moyenne)',
        minPrice = 270,
        maxPrice = 470,
        sellChance = {
            [40] = 90,
            [60] = 70,
            [80] = 40,
            [100] = 10
        }
    },
    {
        item = 'tequila_high',
        label = 'Tequila (Bonne qualité)',
        minPrice = 430,
        maxPrice = 720,
        sellChance = {
            [40] = 90,
            [60] = 70,
            [80] = 40,
            [100] = 10
        }
    },

    -- ============================================
    -- MOONSHINE
    -- ============================================
    {
        item = 'moonshine_low',
        label = 'Moonshine (Mauvaise qualité)',
        minPrice = 150,
        maxPrice = 290,
        sellChance = {
            [40] = 90,
            [60] = 70,
            [80] = 40,
            [100] = 10
        }
    },
    {
        item = 'moonshine_mid',
        label = 'Moonshine (Qualité moyenne)',
        minPrice = 330,
        maxPrice = 570,
        sellChance = {
            [40] = 90,
            [60] = 70,
            [80] = 40,
            [100] = 10
        }
    },
    {
        item = 'moonshine_high',
        label = 'Moonshine (Bonne qualité)',
        minPrice = 520,
        maxPrice = 800,
        sellChance = {
            [40] = 90,
            [60] = 70,
            [80] = 40,
            [100] = 10
        }
    },

    -- ============================================
    -- SAKE
    -- ============================================
    {
        item = 'sake_low',
        label = 'Sake (Mauvaise qualité)',
        minPrice = 140,
        maxPrice = 260,
        sellChance = {
            [40] = 90,
            [60] = 70,
            [80] = 40,
            [100] = 10
        }
    },
    {
        item = 'sake_mid',
        label = 'Sake (Qualité moyenne)',
        minPrice = 290,
        maxPrice = 510,
        sellChance = {
            [40] = 90,
            [60] = 70,
            [80] = 40,
            [100] = 10
        }
    },
    {
        item = 'sake_high',
        label = 'Sake (Bonne qualité)',
        minPrice = 480,
        maxPrice = 800,
        sellChance = {
            [40] = 90,
            [60] = 70,
            [80] = 40,
            [100] = 10
        }
    },

    -- ============================================
    -- COGNAC
    -- ============================================
    {
        item = 'cognac_low',
        label = 'Cognac (Mauvaise qualité)',
        minPrice = 200,
        maxPrice = 360,
        sellChance = {
            [40] = 90,
            [60] = 70,
            [80] = 40,
            [100] = 10
        }
    },
    {
        item = 'cognac_mid',
        label = 'Cognac (Qualité moyenne)',
        minPrice = 400,
        maxPrice = 700,
        sellChance = {
            [40] = 90,
            [60] = 70,
            [80] = 40,
            [100] = 10
        }
    },
    {
        item = 'cognac_high',
        label = 'Cognac (Bonne qualité)',
        minPrice = 670,
        maxPrice = 800,
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
    accept = 30,    -- 30% chance d'accepter
    refuse = 10,    -- 10% chance de refuser
    steal = 10,     -- 10% chance de voler
    callCops = 50   -- 50% chance d'appeler les flics (désactivé en debug)
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
