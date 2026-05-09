fx_version("cerulean")
game("gta5")
lua54("yes")

version '1.0.8'
repository 'https://www.github.com/PulsarFW/pulsar-admin'

client_script("@pulsar-core/exports/cl_error.lua")
client_script("@pulsar-pwnzor/client/check.lua")

-- shared_scripts {
--     'config/*.lua'
-- }

client_scripts({
  "@ox_lib/init.lua",
  "client/client.lua",
  "client/attach.lua",
  "client/noclip/*.lua",
  -- 'client/menu.lua',
  -- 'client/shitty_menu.lua',
  "client/nui.lua",
  "client/ids.lua",
  "client/nuke.lua",
  "client/damage_test.lua",
  "client/doorlock.lua",
})

server_scripts({
  "@oxmysql/lib/MySQL.lua",
  "server/doorlock.lua",
  "server/callbacks.lua",
  "server/dashboard.lua",
  "server/server.lua",
})

ui_page("ui/dist/index.html")

files({ "ui/dist/index.html", "ui/dist/*.js" })
