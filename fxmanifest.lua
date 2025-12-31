fx_version 'cerulean'
game 'gta5'

author 'ZaK2BaK'
description 'Script de vente de drogue avec négociation et NUI moderne'
version '1.0.0'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'locales/*.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}

ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/style.css',
    'nui/script.js',
    'nui/police_alert.js',
    'sounds/police_alert.ogg'
}

dependencies {
    'ox_lib',
    'ox_target',
    'ox_inventory'
}
