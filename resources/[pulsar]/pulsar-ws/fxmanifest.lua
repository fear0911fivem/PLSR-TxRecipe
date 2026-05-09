author("Dr Nick")
lua54("yes")
fx_version("cerulean")
game("gta5")

version "1.0.4"
repository("https://www.github.com/PulsarFW/pulsar-ws")

server_only("yes")

server_scripts({
  "*.js",
  "namespaces/*.js",
  "server/main.lua"
})

files {
  "cert.pem",
  "key.pem"
}
