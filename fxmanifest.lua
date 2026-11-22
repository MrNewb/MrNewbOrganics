fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'MrNewbOrganics'
author 'MrNewb'
description 'Fruit picking, vegetable harvesting, and a farmers market built on Newb_Bridge'
version '1.0.3'

ox_libs {
    'locale',
}

shared_scripts {
    '@ox_lib/init.lua',
    '@Newb_Bridge/import.lua',
    'resource/open/shared/config.lua',
    'resource/modules/core/shared/helpers.lua',
    'resource/modules/picking/shared/picking.lua',
}

client_scripts {
    'resource/modules/picking/client/picking.lua',
    'resource/modules/market/client/market.lua',
}

server_scripts {
    'resource/modules/core/server/helpers.lua',
    'resource/modules/picking/server/picking.lua',
    'resource/modules/market/server/market.lua',
}

files {
    'locales/*.json',
}

dependencies {
    '/server:6116',
    '/onesync',
    'ox_lib',
    'Newb_Bridge',
}

escrow_ignore {
    '**/*',
}
