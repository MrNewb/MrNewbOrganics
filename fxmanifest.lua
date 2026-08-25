fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'MrNewbOrganics'
author 'MrNewb'
description 'Fruit picking, vegetable harvesting, and a farmers market built on Newb_Bridge'
version '1.0.2'

shared_scripts {
    '@ox_lib/init.lua',
    '@Newb_Bridge/import.lua',
    'configs/*.lua',
    'resource/shared/locale.lua',
}

client_scripts {
    'resource/client/fruit_picking.lua',
    'resource/client/farmers_market.lua',
}

server_scripts {
    'resource/server/fruit_picking.lua',
    'resource/server/farmers_market.lua',
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
    'configs/*.lua',
    'locales/*.json',
    'resource/**/*.lua',
}
