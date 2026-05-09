function RegisterJobCallbacks()
	exports["pulsar-core"]:RegisterServerCallback("Jobs:OnDuty", function(source, jobId, cb)
		cb(exports['pulsar-jobs']:DutyOn(source, jobId))
	end)

	exports["pulsar-core"]:RegisterServerCallback("Jobs:OffDuty", function(source, jobId, cb)
		cb(exports['pulsar-jobs']:DutyOff(source, jobId))
	end)
	exports["pulsar-core"]:RegisterServerCallback("MetalDetector:Server:Sync", function(source, data, cb)
		TriggerClientEvent("MetalDetector:Client:Sync", -1, data)
		cb(true)
	end)
end
