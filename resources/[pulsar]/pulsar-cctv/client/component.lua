createdCamera = 0
globalWait = 10
globalCamera = 0
hacking = false
inCamera = false
low = "CAMERA_secuirity"
offlineCam = "Broken_camera_fuzz"

local cameraActive = false
local allowedToSwitch = false
local currentCameraIndex = 0
local currentCameraIndexIndex = 0
local currentTimecycle = nil
local offline = false
local canrotate = false

AddEventHandler('onClientResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Wait(1000)
		RegisterKeyBinds()
	end
end)

exports('View', function(camId)
	local camKey = string.format("CCTV:Camera:%s", camId)
	EnterCam(camId)
end)

exports('Close', function()
	if LocalPlayer.state.inCCTVCam then
		ExitCam()
	end
end)
