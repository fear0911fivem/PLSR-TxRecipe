exports('Notification', function(source, notifType, message, duration, icon, style, id)
    if duration == nil then
        duration = 2500
    end

    local notification = {
        type = notifType,
        message = message,
        duration = duration,
        icon = icon,
    }

    if style then
        notification.style = style
    end

    if duration == -1 then -- If duration = -1, the notification will be persistent
        if id == nil then
            return
        end
        notification._id = id
    end

    if notification.type == "remove" then
        TriggerClientEvent("HUD:Client:NotificationRemove", source, id)
    end

    if notification.type == "clear" then
        TriggerClientEvent("HUD:Client:NotificationClear", source)
    end

    TriggerClientEvent("HUD:Client:Notification", source, notification)
end)
