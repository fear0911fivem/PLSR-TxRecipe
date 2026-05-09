function Startup()
	LAPTOP_APPS = {}
	for k, v in ipairs(_appData) do
		LAPTOP_APPS[v.name] = v
	end
end
