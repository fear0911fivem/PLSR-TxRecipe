local linkPromise
function GetNewTVLink(id)
    local width = 512
    local height = 512
    if id and _billboardConfig[id] then
        width = _billboardConfig[id].width
        height = _billboardConfig[id].height
    end

    linkPromise = promise.new()
    exports['pulsar-hud']:InputShow("Set Link", "Allowed URLS: Imgur, ImgBB, Postimages, Fivemanage", {
        {
            id = "name",
            type = "text",
            options = {
                helperText = string.format("Leave Blank to Reset - Resolution: %s x %s", width, height),
                inputProps = {},
            },
        },
    }, "Billboards:Client:RecieveTVLinkInput", {})

    return Citizen.Await(linkPromise)
end

AddEventHandler("Billboards:Client:RecieveTVLinkInput", function(values)
    if linkPromise then
        linkPromise:resolve(values?.name)
        linkPromise = nil
    end
end)

AddEventHandler("Billboards:Client:SetLink", function(data)
    local tvLink = GetNewTVLink(data.id)
    exports["pulsar-core"]:ServerCallback("Billboards:UpdateURL", {
        id = data.id,
        link = tvLink
    }, function(success, invalidUrl)
        if success then
            exports["pulsar-hud"]:Notification("success", "Updated Link!", 5000)
        else
            if invalidUrl then
                exports["pulsar-hud"]:Notification("error", "Invalid URL - Check the image host/url", 5000)
            else
                exports["pulsar-hud"]:Notification("error", "Unable to Update Link", 5000)
            end
        end
    end)
end)
