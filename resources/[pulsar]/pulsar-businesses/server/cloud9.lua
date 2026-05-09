_DRIFTLICENSECOST = 25000

AddEventHandler("Businesses:Server:Startup", function()
	exports["pulsar-chat"]:RegisterCommand(
		"checkdriftlicense",
		function(source, args, rawCommand)
			if tonumber(args[1]) then
				local char = exports['pulsar-characters']:FetchBySID(tonumber(args[1]))
				if char ~= nil then
					exports["pulsar-chat"]:SendSystemSingle(
						source,
						string.format("Drift License: %s", _DRIFT:Check(tonumber(args[1]), source))
					)
				else
					exports["pulsar-chat"]:SendSystemSingle(source, "State ID Not Logged In")
				end
			else
				exports["pulsar-chat"]:SendSystemSingle(source, "Invalid Arguments")
			end
		end,
		{
			help = "Check State DMV for Drift License",
			params = {
				{
					name = "Target",
					help = "State ID of target",
				},
			},
		},
		1,
		{
			{
				Id = "cloud9",
			},
		}
	)
	exports["pulsar-chat"]:RegisterCommand(
		"revokedriftlicense",
		function(source, args, rawCommand)
			if tonumber(args[1]) then
				local char = exports['pulsar-characters']:FetchBySID(tonumber(args[1]))
				if char ~= nil then
					_DRIFT:Revoke(tonumber(args[1]), source)
				else
					exports["pulsar-chat"]:SendSystemSingle(source, "State ID Not Logged In")
				end
			else
				exports["pulsar-chat"]:SendSystemSingle(source, "Invalid Arguments")
			end
		end,
		{
			help = "Revoke Drift License",
			params = {
				{
					name = "Target",
					help = "State ID of target",
				},
			},
		},
		1,
		{
			{
				Id = "cloud9",
			},
		}
	)
	exports["pulsar-chat"]:RegisterCommand(
		"adddriftlicense",
		function(source, args, rawCommand)
			if tonumber(args[1]) then
				local char = exports['pulsar-characters']:FetchBySID(tonumber(args[1]))
				if char ~= nil then
					_DRIFT:Give(tonumber(args[1]), source)
				else
					exports["pulsar-chat"]:SendSystemSingle(source, "State ID Not Logged In")
				end
			else
				exports["pulsar-chat"]:SendSystemSingle(source, "Invalid Arguments")
			end
		end,
		{
			help = "Give Drift License",
			params = {
				{
					name = "Target",
					help = "State ID of target",
				},
			},
		},
		1,
		{
			{
				Id = "cloud9",
			},
		}
	)
end)

_DRIFT = {
	Revoke = function(self, sid, source)
		if exports['pulsar-jobs']:HasPermissionInJob(source, "cloud9", "JOB_DRIFT_LICENSE") then
			local char = exports['pulsar-characters']:FetchBySID(tonumber(sid))
			if char then
				local licenses = char:GetData("Licenses")
				local targetSrc = char:GetData("Source")
				if licenses["Drift"].Active ~= nil and licenses["Drift"].Active == true then
					licenses["Drift"].Active = false
					licenses["Drift"].Suspended = true
					char:SetData("Licenses", licenses)
					exports['pulsar-core']:MiddlewareTriggerEvent("Characters:ForceStore", targetSrc)
					exports['pulsar-hud']:Notification(targetSrc, "error", "Your Drift License has been revoked.")
					exports['pulsar-hud']:Notification(source, "success",
						"Revoking Drift License Successful")
				end
			else
				exports['pulsar-hud']:Notification(source, "error", "State ID Not Logged In")
			end
		else
			exports['pulsar-hud']:Notification(source, "error", "Insufficient Privileges")
		end
	end,
	Give = function(self, sid, source)
		if exports['pulsar-jobs']:HasPermissionInJob(source, "cloud9", "JOB_DRIFT_LICENSE") then
			local char = exports['pulsar-characters']:FetchBySID(tonumber(sid))
			if char then
				local licenses = char:GetData("Licenses")
				local targetSrc = char:GetData("Source")
				if licenses["Drift"].Active ~= nil and licenses["Drift"].Active == false then
					local PlayerAccount = char:GetData("BankAccount")
					local paymentSuccess = false
					if PlayerAccount then
						paymentSuccess = exports['pulsar-finance']:BalanceCharge(PlayerAccount, _DRIFTLICENSECOST, {
							type = "bill",
							title = "DMV Licenses",
							description = "Drift License Cost",
							data = {},
						})

						if paymentSuccess then
							licenses["Drift"].Suspended = false
							licenses["Drift"].Active = true
							char:SetData("Licenses", licenses)
							exports['pulsar-core']:MiddlewareTriggerEvent("Characters:ForceStore", targetSrc)
							exports['pulsar-phone']:NotificationAdd(
								targetSrc,
								"Payment Successful",
								string.format("Cloud 9 Drift License - $%s", _DRIFTLICENSECOST),
								os.time(),
								3000,
								"bank",
								{}
							)
							local f = exports['pulsar-finance']:AccountsGetOrganization("cloud9")
							exports['pulsar-finance']:BalanceDeposit(f.Account, math.abs(_DRIFTLICENSECOST), {
								type = "deposit",
								title = "Cloud 9",
								description = string.format(
									"Cloud 9 Drift License - %s %s",
									char:GetData("First"),
									char:GetData("Last")
								),
								data = {},
							}, true)
							exports['pulsar-hud']:Notification(targetSrc, "success", "You've received a Drift License.")
							exports['pulsar-hud']:Notification(source, "success",
								"Drift License Given Successfully")
						else
							exports['pulsar-hud']:Notification(source, "error",
								"Bank: Declined - Insufficient Funds")
						end
					end
				else
					exports['pulsar-hud']:Notification(source, "error",
						"Drift License already exists!")
				end
			else
				exports['pulsar-hud']:Notification(source, "error", "State ID Not Logged In")
			end
		else
			exports['pulsar-hud']:Notification(source, "error", "Insufficient Privileges")
		end
	end,
	Check = function(self, sid, source)
		local char = exports['pulsar-characters']:FetchBySID(tonumber(sid))
		if char then
			local licenses = char:GetData("Licenses")
			return licenses["Drift"].Active or false
		end
		return false
	end,
}
