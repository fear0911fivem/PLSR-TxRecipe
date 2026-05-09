exports("StoreInstallCheck", function(app, method)
	-- As of now, just pass true, idfk if we doing this shti
	Wait(5e3)
	return method == "store"
end)

exports("StoreInstallDo", function(app, apps, method)
	if not hasValue(apps.installed, app) then
		table.insert(apps.installed, app)
		if #apps.home < 20 then
			table.insert(apps.home, app)
		end
	end
	return apps
end)

exports("StoreUninstallCheck", function(app)
	Wait(5e3)
	return true
end)

exports("StoreUninstallDo", function(app, apps)
	local newApps = { installed = {}, home = {}, dock = {} }
	for k, v in ipairs(apps.installed) do
		if v ~= app then
			table.insert(newApps.installed, v)
		end
	end
	for k, v in ipairs(apps.home) do
		if v ~= app then
			table.insert(newApps.home, v)
		end
	end
	for k, v in ipairs(apps.dock) do
		if v ~= app then
			table.insert(newApps.dock, v)
		end
	end
	return newApps
end)

AddEventHandler("Phone:Server:RegisterCallbacks", function()
	exports["pulsar-core"]:RegisterServerCallback("Phone:Store:Install:Check", function(src, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(src)
		CreateThread(function()
			cb(exports['pulsar-phone']:StoreInstallCheck(data))
		end)
	end)
	exports["pulsar-core"]:RegisterServerCallback("Phone:Store:Install:Do", function(src, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(src)
		CreateThread(function()
			char:SetData("Apps", exports['pulsar-phone']:StoreInstallDo(data, char:GetData("Apps"), "store"))
			cb(true, PHONE_APPS[data], os.time())
		end)
	end)
	exports["pulsar-core"]:RegisterServerCallback("Phone:Store:Uninstall:Check", function(src, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(src)
		CreateThread(function()
			cb(exports['pulsar-phone']:StoreUninstallCheck(data))
		end)
	end)
	exports["pulsar-core"]:RegisterServerCallback("Phone:Store:Uninstall:Do", function(src, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(src)
		CreateThread(function()
			local nApps = exports['pulsar-phone']:StoreUninstallDo(data, char:GetData("Apps"))
			char:SetData("Apps", nApps)
			cb(true)
		end)
	end)
end)
