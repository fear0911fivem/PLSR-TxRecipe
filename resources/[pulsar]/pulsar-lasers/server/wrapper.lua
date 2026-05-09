AddEventHandler('onResourceStart', function(resource)
   	if resource == GetCurrentResourceName() then
		Wait(1000)
    exports['pulsar-core']:VersionCheck('PulsarFW/pulsar-lasers')
    exports["pulsar-chat"]:RegisterAdminCommand("lasers", function(source, args, rawCommand)
        if args[1] == "start" then
            exports["pulsar-core"]:ClientCallback(source, "Lasers:Create:Start")
        elseif args[1] == "end" then
            exports["pulsar-core"]:ClientCallback(source, "Lasers:Create:End")
        elseif args[1] == "save" then
            exports["pulsar-core"]:ClientCallback(source, "Lasers:Create:Save")
        else

    end, {
        help = "Create Lasers",
        params = {
            {
                name = "Action",
                help = "Action to perform (start, end, save)",
            },
        },
    }, 1)
   end
end)