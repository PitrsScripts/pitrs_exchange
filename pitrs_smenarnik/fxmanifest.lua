fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Pitrs'
description 'Pitrs exchange script'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    'config.lua',
    '@ox_lib/init.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

dependencies {
    'es_extended',
    'ox_lib'
}