-- RegisterNetEvent("Confirm:Client:Test", function()
-- 	exports['pulsar-hud']:ConfirmShow(
-- 		"Test Input",
-- 		{
-- 			yes = "Confirm:Test:Yes",
-- 			no = "Confirm:Test:No",
-- 		},
-- 		"This is a test confirm dialog, neat",
-- 		{
-- 			test = "penis",
-- 		}
-- 	)
-- end)

local _isOpen = false

exports("InfoOverlayShow", function(title, description)
	_isOpen = true

	SendNUIMessage({
		type = "SHOW_INFO_OVERLAY",
		data = {
			info = {
				label = title,
				description = description,
			},
		},
	})
end)

exports("InfoOverlayClose", function()
	_isOpen = false

	SendNUIMessage({
		type = "CLOSE_INFO_OVERLAY",
	})
end)

exports("InfoOverlayIsOpen", function()
	return _isOpen
end)
