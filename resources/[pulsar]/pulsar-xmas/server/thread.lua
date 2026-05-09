local _threading = false
function StartThreading()
    if _threading then return end
    _threading = true

    CreateThread(function()
        while true do
            Wait((1000 * 60 * 60) * 4)
            GenerateNewTree()
        end
    end)
end
