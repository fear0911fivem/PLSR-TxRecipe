fx_version("cerulean")
games({ "gta5" })
lua54("yes")

version '1.0.2'
repository 'https://www.github.com/PularFW/pulsar-animations'

client_script("@pulsar-core/exports/cl_error.lua")
client_script("@pulsar-pwnzor/client/check.lua")

client_scripts({
  "config/*.lua",
  "client/utils.lua",
  "client/main.lua",
  "client/menu.lua",
  "client/bindings.lua",
  "client/emotes.lua",
  "client/ptfxsync.lua",
  "client/pedfeatures.lua",
  "client/sharedemotes.lua",
  "client/pointing.lua",
  "client/items.lua",
  "client/chairs.lua",
  "client/selfie.lua",
})

server_scripts({
  "config/*.lua",
  "server/*.lua",
})

shared_scripts({
  "shared/**/*.lua",
})
