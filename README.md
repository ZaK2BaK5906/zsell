# Z-SELL - Script de Vente de Drogue

Un script FiveM moderne pour la vente de drogue avec négociation, interface utilisateur propre et comportements variés des PNJ.

## 🌟 Fonctionnalités

- **Interface moderne** avec design élégant (gradient violet/bleu)
- **Système de négociation** avec les PNJ
- **Comportements variés des PNJ** :
  - Acceptation de la vente
  - Refus de l'offre
  - Vol de la marchandise et fuite
  - Appel à la police (désactivable en mode debug)
- **Sélection multi-drogue** si vous possédez plusieurs types
- **Prix dynamiques** avec indicateur de risque
- **Système de chance** basé sur le prix demandé
- **Entièrement configurable**
- **Support multilingue** (FR/DE)

## 📦 Dépendances

- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_target](https://github.com/overextended/ox_target)
- [ox_inventory](https://github.com/overextended/ox_inventory)

## 🔧 Installation

1. Téléchargez le script et placez-le dans votre dossier `resources`
2. Ajoutez `ensure zsell` dans votre `server.cfg`
3. Configurez le script dans `config.lua`
4. Ajoutez les items suivants dans `ox_inventory` :
   - `pochon_weed`
   - `pochon_cocaine`
   - `pochon_meth`
5. Redémarrez votre serveur

## ⚙️ Configuration

### Drogues vendables (`Config.Drugs`)

```lua
{
    item = 'pochon_weed',
    label = 'Weed',
    minPrice = 200,
    maxPrice = 500,
    sellChance = {
        [40] = 90,  -- 40% du prix max = 90% de chance
        [60] = 70,  -- 60% du prix max = 70% de chance
        [80] = 40,  -- 80% du prix max = 40% de chance
        [100] = 10  -- 100% du prix max = 10% de chance
    }
}
```

### Comportements PNJ (`Config.NPCBehavior`)

```lua
accept = 50,    -- 50% chance d'accepter
refuse = 30,    -- 30% chance de refuser
steal = 15,     -- 15% chance de voler
callCops = 5    -- 5% chance d'appeler les flics
```

### Emplacements des dealers (`Config.PedLocations`)

```lua
{
    coords = vector4(127.22, -1930.24, 20.38, 320.0),
    scenario = 'WORLD_HUMAN_SMOKING'
}
```

### Mode Debug

En mode debug (`Config.Debug = true`) :
- Pas d'alerte police
- Logs détaillés dans la console
- Idéal pour les tests

## 🎮 Utilisation

1. Approchez-vous d'un PNJ dealer (marqué par l'icône cannabis)
2. Utilisez ox_target pour ouvrir l'interface
3. Sélectionnez la drogue à vendre
4. Fixez votre prix et la quantité
5. Lancez la négociation

**Conseils** :
- Prix bas = Plus de chance de vendre
- Prix élevé = Plus de risque de refus ou vol
- L'indicateur de couleur vous guide sur le risque

## 🎨 Personnalisation

### Ajouter une nouvelle drogue

1. Ajoutez la configuration dans `Config.Drugs`
2. Ajoutez les traductions dans les fichiers `locales/`
3. L'item doit exister dans `ox_inventory`

### Modifier l'interface

- `nui/style.css` : Styles et couleurs
- `nui/index.html` : Structure HTML
- `nui/script.js` : Logique JavaScript

### Ajouter des emplacements de dealers

Ajoutez simplement de nouvelles coordonnées dans `Config.PedLocations`

## 🔒 Sécurité

- Toutes les ventes sont validées côté serveur
- Vérification de l'inventaire du joueur
- Protection contre les exploits de prix
- Système de PNJ occupés pour éviter les abus

## 🐛 Debug

Pour activer les logs de debug :
```lua
Config.Debug = true
```

Les logs afficheront :
- Nombre de PNJ spawn
- Actions des PNJ
- Détails des ventes
- Chances de vente calculées

## 📝 Support

Pour toute question ou problème, créez une issue sur GitHub.

## 📜 Licence

Ce script est fourni "tel quel" sans garantie. Utilisez-le à vos propres risques.

## 🎯 Crédits

- Développé par ZaK2BaK
- Interface inspirée par les designs modernes
- Compatible avec le framework ESX/QBCore (via ox_inventory)
