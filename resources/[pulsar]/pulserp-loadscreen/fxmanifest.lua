fx_version("cerulean")
games({ "gta5" })
lua54("yes")

author "Icedog"
description "Completed the unfinished sandbox-loadscreen resource"
client_script("@pulsar-base/components/cl_error.lua")
client_script("@pulsar-pwnzor/client/check.lua")

loadscreen("ui/html/index.html")

loadscreen_manual_shutdown("yes")

files({
	"ui/html/*.*",
})
