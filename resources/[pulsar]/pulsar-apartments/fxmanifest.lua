fx_version("cerulean")
games({ "gta5" })
lua54("yes")

ui_page("web/build/index.html")

files({
	"web/build/index.html",
	"web/build/**/*",
})

client_script("@pulsar-core/exports/cl_error.lua")
client_script("@pulsar-pwnzor/client/check.lua")

shared_scripts({
	"@ox_lib/init.lua",
	"shared/door_import.lua",
	"shared/apartment_doors.lua",
	"shared/config.lua",
	"shared/wiwang_rooms.lua",
})

client_scripts({
	"client/**/*.lua",
})

server_scripts({
	"@oxmysql/lib/MySQL.lua",
	"server/**/*.lua",
})
