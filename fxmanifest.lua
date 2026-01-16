fx_version 'cerulean'
game 'gta5'
lua54 'yes'
name 'MrNewbOrganics'
author 'MrNewb'
description 'A simple fruit picking script featuring prop spawning, zone targeting, and item rewards. Built as a practical exercise in metatable implementation.'
version '0.0.2'

shared_scripts {
	'core/init.lua',
	'configs/**/*.lua',
}

client_scripts {
	'modules/**/client.lua',
}

server_scripts {
	'modules/**/server.lua',
}

files {
	'locales/*.json'
}

dependencies {
	'/server:6116',
	'/onesync',
	'community_bridge',
}

escrow_ignore {
	'**/*.lua',
}