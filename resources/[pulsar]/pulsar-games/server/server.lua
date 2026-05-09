local _uircd = {}

AddEventHandler('onResourceStart', function(resource)
  if resource == GetCurrentResourceName() then
    Wait(1000)
    RegisterChatCommands()
    exports['pulsar-core']:VersionCheck('PulsarFW/pulsar-games')
  end
end)

function RegisterChatCommands()
  -- exports["pulsar-chat"]:RegisterAdminCommand("notif", function(source, args, rawCommand)
  -- 	exports['pulsar-hud']:Notification(source, "success", "This is a test, lul")
  -- end, {
  -- 	help = "Test Notification",
  -- })

  -- exports["pulsar-chat"]:RegisterAdminCommand("list", function(source, args, rawCommand)
  -- 	TriggerClientEvent("ListMenu:Client:Test", source)
  -- end, {
  -- 	help = "Test List Menu",
  -- })

  -- exports["pulsar-chat"]:RegisterAdminCommand("input", function(source, args, rawCommand)
  -- 	TriggerClientEvent("Input:Client:Test", source)
  -- end, {
  -- 	help = "Test Input",
  -- })

  -- exports["pulsar-chat"]:RegisterAdminCommand("confirm", function(source, args, rawCommand)
  -- 	TriggerClientEvent("Confirm:Client:Test", source)
  -- end, {
  -- 	help = "Test Confirm Dialog",
  -- })

  -- exports["pulsar-chat"]:RegisterAdminCommand("skill", function(source, args, rawCommand)
  -- 	TriggerClientEvent("Minigame:Client:Skillbar", source)
  -- end, {
  -- 	help = "Test Skill Bar",
  -- })

  -- exports["pulsar-chat"]:RegisterAdminCommand("scan", function(source, args, rawCommand)
  -- 	TriggerClientEvent("Minigame:Client:Scanner", source)
  -- end, {
  -- 	help = "Test Scanner",
  -- })

  -- exports["pulsar-chat"]:RegisterAdminCommand("sequencer", function(source, args, rawCommand)
  -- 	TriggerClientEvent("Minigame:Client:Sequencer", source)
  -- end, {
  -- 	help = "Test Sequencer",
  -- })

  -- exports["pulsar-chat"]:RegisterAdminCommand("keypad", function(source, args, rawCommand)
  -- 	TriggerClientEvent("Minigame:Client:Keypad", source)
  -- end, {
  -- 	help = "Test Keypad",
  -- })

  -- exports["pulsar-chat"]:RegisterAdminCommand("scrambler", function(source, args, rawCommand)
  -- 	TriggerClientEvent("Minigame:Client:Scrambler", source)
  -- end, {
  -- 	help = "Test Scrambler",
  -- })

  -- exports["pulsar-chat"]:RegisterAdminCommand("memory", function(source, args, rawCommand)
  -- 	TriggerClientEvent("Minigame:Client:Memory", source)
  -- end, {
  -- 	help = "Test Memory",
  -- })
end
