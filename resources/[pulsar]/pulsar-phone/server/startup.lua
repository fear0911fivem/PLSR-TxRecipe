function Startup()
	PHONE_APPS = {}
	for k, v in ipairs(_appData) do
		PHONE_APPS[v.name] = v
	end
end
