local inEmoteMenu, inEmoteSubMenu, inFeaturesMenu = false, false, false

local cachedEmoteMenu

exports("OpenMainEmoteMenu", function()
    if not cachedEmoteMenu then
        local emoteMenu = {
            main = {
                label = 'Emotes',
                items = {
                    {
                        label = 'Emote Binds',
                        description = 'Edit Your Emote Binds',
                        event = 'Animations:Client:OpenEmoteBinds',
                    },
                    {
                        label = 'Prop Emotes',
                        description = 'Emotes',
                        submenu = 'emotes-prop',
                    },
                    {
                        label = 'Dance Emotes',
                        description = 'Emotes',
                        submenu = 'emotes-dance',
                    },
                },
            },
            ['emotes-prop'] = {
                label = 'Prop Emotes',
                items = {},
            },
            ['emotes-dance'] = {
                label = 'Dance Emotes',
                items = {},
            }
        }

        for k, v in pairs(Config.EmoteNaming.regular) do
            if k ~= "doggo" then
                local emoteSub = 'emotes-' .. k

                table.insert(emoteMenu.main.items, {
                    label = v.name,
                    description = 'Emotes',
                    submenu = emoteSub,
                })

                local subItems = {}

                for _, emote in ipairs(v.emotes) do
                    table.insert(subItems, {
                        label = emote[2],
                        description = '/e ' .. emote[1],
                        event = 'Animations:Client:EmoteMenuEmote',
                        data = emote[1]
                    })
                end

                emoteMenu[emoteSub] = {
                    label = v.name,
                    items = subItems,
                }
            end
        end

        for _, emote in ipairs(Config.EmoteNaming.prop) do
            table.insert(emoteMenu['emotes-prop'].items, {
                label = emote[2],
                description = '/e ' .. emote[1],
                event = 'Animations:Client:EmoteMenuEmote',
                data = emote[1]
            })
        end

        for _, emote in ipairs(Config.EmoteNaming.dance) do
            table.insert(emoteMenu['emotes-dance'].items, {
                label = emote[2],
                description = '/e ' .. emote[1],
                event = 'Animations:Client:EmoteMenuEmote',
                data = emote[1]
            })
        end

        cachedEmoteMenu = emoteMenu
    end

    exports['pulsar-hud']:ListMenuShow(cachedEmoteMenu)
end)

exports("OpenWalksMenu", function(fromMainMenu)
    local emoteMenu = {
        main = {
            label = 'Walk Styles',
            items = {
                {
                    label = 'Reset',
                    description = 'Reset Walk Style to Default',
                    event = 'Animations:Client:EmoteMenuWalkStyle',
                    data = {
                        walk = 'reset',
                        label = false,
                    }
                }
            },
        },
    }

    for k, v in spairs(Config.Walks) do
        table.insert(emoteMenu.main.items, {
            label = k,
            event = 'Animations:Client:EmoteMenuWalkStyle',
            data = {
                walk = v,
                label = k,
            }
        })
    end

    exports['pulsar-hud']:ListMenuShow(emoteMenu)
end)

exports("OpenExpressionsMenu", function()
    local emoteMenu = {
        main = {
            label = 'Facial Expressions',
            items = {
                {
                    label = 'Reset',
                    description = 'Reset Expressions to Default',
                    event = 'Animations:Client:EmoteMenuExpressions',
                    data = {
                        exp = 'reset',
                        label = false,
                    }
                }
            },
        },
    }

    for k, v in spairs(Config.Expressions) do
        table.insert(emoteMenu.main.items, {
            label = k,
            event = 'Animations:Client:EmoteMenuExpressions',
            data = {
                exp = v,
                label = k,
            }
        })
    end

    exports['pulsar-hud']:ListMenuShow(emoteMenu)
end)

AddEventHandler('Animations:Client:EmoteMenuEmote', function(data)
    exports['pulsar-animations']:EmotesPlay(data, true)
    Wait(250)
    exports['pulsar-animations']:OpenMainEmoteMenu()
end)

AddEventHandler('Animations:Client:EmoteMenuWalkStyle', function(data)
    exports['pulsar-animations']:PedFeaturesSetWalk(data.walk, data.label)
end)

AddEventHandler('Animations:Client:EmoteMenuExpressions', function(data)
    exports['pulsar-animations']:PedFeaturesSetExpression(data.exp, data.label)
end)
