function RegisterCallbacks()
	exports["pulsar-core"]:RegisterServerCallback("Labor:GetJobs", function(source, data, cb)
		cb(exports['pulsar-labor']:GetJobs())
	end)
	exports["pulsar-core"]:RegisterServerCallback("Labor:GetGroups", function(source, data, cb)
		cb(exports['pulsar-labor']:GetGroups())
	end)

	exports["pulsar-core"]:RegisterServerCallback("Labor:GetReputations", function(source, data, cb)
		cb(exports['pulsar-characters']:RepView(source))
	end)

	exports["pulsar-core"]:RegisterServerCallback("Labor:AcceptRequest", function(source, data, cb)
		if _pendingInvites[data.source] ~= nil then
			local state = exports['pulsar-labor']:JoinWorkgroup(_pendingInvites[data.source], data.source)

			if state then
				exports['pulsar-phone']:NotificationAdd(
					data.source,
					"Job Activity",
					"You Joined A Workgroup",
					os.time(),
					6000,
					"labor",
					{}
				)
			end

			_pendingInvites[data.source] = nil
			cb(state)
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Labor:DeclineRequest", function(source, data, cb)
		if _pendingInvites[data.source] ~= nil then
			_pendingInvites[data.source] = nil

			exports['pulsar-phone']:NotificationAdd(
				data.source,
				"Job Activity",
				"Your Group Request Was Denied",
				os.time(),
				6000,
				"labor",
				{}
			)

			exports['pulsar-phone']:NotificationAdd(
				source,
				"Labor Activity",
				"You Denied A Group Request",
				os.time(),
				6000,
				"labor",
				{}
			)

			cb(true)
		else
			cb(false)
		end
	end)
end
