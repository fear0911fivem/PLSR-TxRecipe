fx_version("cerulean")
games({ "gta5" })
lua54("yes")
version '1.0.2'
client_script("@pulsar-core/exports/cl_error.lua")
client_script("@pulsar-pwnzor/client/check.lua")

client_scripts({
  "client/*.lua",
})

server_scripts({
  "server/*.lua",
})

ui_page("ui/dist/index.html")
files({
  "ui/dist/index.html",
  "ui/dist/*.png",
  "ui/dist/*.webp",
  "ui/dist/*.js",
  "ui/dist/*.mp3",
  "ui/dist/*.ttf",
})
