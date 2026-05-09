fx_version "cerulean"
game 'gta5'
lua54 'yes'
description "Pulsar Loading Screen"
author "Pulsar"
version '1.0.4'

server_script 'server/version.lua'

loadscreen 'web/build/index.html'
loadscreen_manual_shutdown 'yes'

files {
  'web/build/index.html',
  'web/build/**/*',
}
