AddEventHandler('onClientResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Wait(1000)
		PrisonHospitalInit()
		PrisonVisitation()
	end
end)
