name "DJBooth"
author "katahtonic"
version "1.0.1"
description 'DJBooth Edit By Katahtonic'
fx_version "cerulean"
game "gta5"

client_scripts {
  "@pulsar-polyzone/client.lua",
  "@pulsar-polyzone/BoxZone.lua",
  "@pulsar-polyzone/EntityZone.lua",
  "@pulsar-polyzone/CircleZone.lua",
  "@pulsar-polyzone/ComboZone.lua",
  'client.lua'
}

shared_script { 'config.lua' }
server_script { 'server.lua' }

dependency 'xsound'

lua54 'yes'
