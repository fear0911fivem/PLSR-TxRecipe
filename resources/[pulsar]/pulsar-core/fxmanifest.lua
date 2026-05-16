fx_version("cerulean")
games({ "gta5" })
lua54("yes")
version "1.0.7"
repository("https://www.github.com/PulsarFW/pulsar-core")
server_script("@oxmysql/lib/MySQL.lua")
client_script("@pulsar-pwnzor/client/check.lua")
client_scripts({
  "sh_init.lua",
  "core/sh_*.lua",
  "core/cl_*.lua",
  "exports/cl_*.lua",
})

server_scripts({
  "sh_init.lua",
  "sv_config.lua",
  "core/sv_generator.js",
  "core/sv_regex.js",
  "core/sh_*.lua",
  "core/sv_*.lua",
  "exports/sv_*.lua",
})

files({
  "weaponanimations.meta",
})

data_file("WEAPONINFO_FILE_PATCH")("weapons.meta")
data_file("WEAPON_ANIMATIONS_FILE")("weaponanimations.meta")

this_is_a_map("yes")
