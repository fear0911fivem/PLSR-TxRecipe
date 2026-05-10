fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'SRP'
description 'Petty Theft'
version '1.0.0'

client_scripts {
    'client/cl_pettytheft.lua',
}

server_scripts {
    'server/sv_pettytheft.lua',
}

dependencies {
    'ox_lib',
    'ox_target',
    'ox_inventory',
    'pulsar-characters',
    'pulsar-core',
    'pulsar-hud',
    'pulsar-kbs',
    'pulsar-vehicles',
}
