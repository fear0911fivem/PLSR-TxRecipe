lua54("yes")
fx_version("cerulean")
game("gta5")
version "1.0.1"
client_script("@pulsar-core/exports/cl_error.lua")
client_script("@pulsar-pwnzor/client/check.lua")

client_scripts({
  "config.lua",
  "client/*.lua",
})

server_scripts({
  "config.lua",
  "server/*.lua",
})

ui_page("ui/dist/index.html")

files({
  "ui/dist/*",
})
