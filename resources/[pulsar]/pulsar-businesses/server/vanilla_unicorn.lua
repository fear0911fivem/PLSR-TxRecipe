AddEventHandler('Businesses:Server:Startup', function()
    exports["pulsar-core"]:RegisterServerCallback('VU:MakeItRain', function(source, data, cb)
        local char = exports['pulsar-characters']:FetchCharacterSource(source)
        local targetChar = exports['pulsar-characters']:FetchCharacterSource(data?.target)

        if char and targetChar and data?.type and Player(targetChar:GetData('Source')).state.onDuty == 'unicorn' then
            local itemData = exports.ox_inventory:ItemsGetData(data.type)
            if data.type == 'cash' then
                if exports['pulsar-finance']:WalletModify(char:GetData('Source'), -100) then
                    exports['pulsar-finance']:WalletModify(targetChar:GetData('Source'), 100)
                    return cb(true)
                end
            elseif itemData then
                if exports.ox_inventory:ItemsHas(char:GetData('SID'), 1, data.type, 1) then
                    if exports.ox_inventory:Remove(char:GetData('SID'), 1, data.type, 1) then
                        exports['pulsar-finance']:WalletModify(targetChar:GetData('Source'),
                            math.floor(itemData.price * 0.1))
                        exports['pulsar-finance']:WalletModify(char:GetData('Source'), math.floor(itemData.price * 0.8))

                        local f = exports['pulsar-finance']:AccountsGetOrganization("unicorn")
                        exports['pulsar-finance']:BalanceDeposit(f.Account, math.floor(itemData.price * 0.05), {
                            type = "deposit",
                            title = "Private Dances",
                            description = string.format("5%% Tax On %s Private Dances", math.floor(itemData.price)),
                            data = data,
                        }, true)

                        return cb(true)
                    end
                end
            end
        end

        cb(false)
    end)
end)
