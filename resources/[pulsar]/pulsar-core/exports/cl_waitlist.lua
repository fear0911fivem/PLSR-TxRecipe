exports("WaitListIsInQueue", function(id)
	local k = LocalPlayer.state[string.format("WaitList:%s", id)]
	return k ~= nil and k.waiting
end)
