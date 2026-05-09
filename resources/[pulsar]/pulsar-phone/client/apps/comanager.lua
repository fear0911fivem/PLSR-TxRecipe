RegisterNetEvent("Phone:Client:CoManager:GetJobOffer", function(time, jobData)
	local message
	if jobData.Workplace then
		message =
			string.format("You've received an employment offer as %s - %s", jobData.Workplace.Name, jobData.Grade.Name)
	else
		message = string.format("You've received an employment offer as %s - %s", jobData.Name, jobData.Grade.Name)
	end
	exports['pulsar-phone']:NotificationAdd(
		"Employment Offer",
		message,
		time,
		-1,
		"comanager",
		{
			accept = "Phone:Client:CoManager:AcceptHire",
			cancel = "Phone:Client:CoManager:DeclineHire",
		},
		nil,
		{
			sound = _settings.texttone,
			volume = 0.1 * (_settings.volume / 100),
		}
	)
end)

RegisterNetEvent("Phone:Client:CoManager:GetOfferResult", function(time, state)
	if state then
		exports['pulsar-phone']:NotificationAdd(
			"Employment Offer Response",
			"Your Employment Offer Was Accepted",
			time,
			6000,
			"comanager",
			{ view = "" },
			nil
		)
	else
		exports['pulsar-phone']:NotificationAdd(
			"Employment Offer Response",
			"Your Employment Offer Was Declined",
			time,
			6000,
			"comanager",
			{ view = "" },
			nil
		)
	end
end)

AddEventHandler("Phone:Client:CoManager:AcceptHire", function()
	exports["pulsar-core"]:ServerCallback("Phone:CoManager:AcceptHire", {}, function(time, state)
		if state then
			exports['pulsar-phone']:NotificationAdd("Employment", "You accepted an employment offer", time, 6000,
				"comanager", {
					view = "",
				}, nil)
		else
			exports['pulsar-phone']:NotificationAdd(
				"Employment",
				"Unable to accept an employment offer",
				time,
				6000,
				"comanager",
				{
					view = "",
				},
				nil
			)
		end
	end)
end)

AddEventHandler("Phone:Client:CoManager:DeclineHire", function()
	exports["pulsar-core"]:ServerCallback("Phone:CoManager:DeclineHire", {}, function(time)
		exports['pulsar-phone']:NotificationAdd(
			"Employment",
			"You declined an employment offer",
			time,
			6000,
			"comanager",
			{},
			nil
		)
	end)
end)

RegisterNetEvent("Phone:Client:CoManager:GetTransferRequest", function(time, data)
	exports['pulsar-phone']:NotificationAdd(
		data.Name,
		string.format("%s Wants To Transfer Ownership of %s", data.Sender, data.Name),
		time,
		-1,
		"comanager",
		{
			accept = "Phone:Client:CoManager:AcceptXfer",
			cancel = "Phone:Client:CoManager:DeclineXfer",
		},
		nil
	)
end)

AddEventHandler("Phone:Client:CoManager:AcceptXfer", function()
	exports["pulsar-core"]:ServerCallback("Phone:CoManager:AcceptXfer", {}, function(time, state)
		if state then
			exports['pulsar-phone']:NotificationAdd(
				"Employment",
				"You accepted an ownership transfer request",
				time,
				6000,
				"comanager",
				{
					view = "",
				},
				nil
			)
		else
			exports['pulsar-phone']:NotificationAdd(
				"Employment",
				"Unable to accept an ownership transfer request",
				time,
				6000,
				"comanager",
				{
					view = "",
				},
				nil
			)
		end
	end)
end)

AddEventHandler("Phone:Client:CoManager:DeclineXfer", function()
	exports["pulsar-core"]:ServerCallback("Phone:CoManager:DeclineXfer", {}, function(time)
		exports['pulsar-phone']:NotificationAdd(
			"Employment",
			"You declined an ownership transfer request",
			time,
			6000,
			"comanager",
			{},
			nil
		)
	end)
end)

RegisterNUICallback("QuitJob", function(data, cb)
	exports["pulsar-core"]:ServerCallback("Phone:CoManager:QuitJob", data, cb)
end)

RegisterNUICallback("FetchRoster", function(data, cb)
	exports["pulsar-core"]:ServerCallback("Phone:CoManager:FetchRoster", data, cb)
end)

RegisterNUICallback("FetchTimeWorked", function(data, cb)
	exports["pulsar-core"]:ServerCallback("Phone:CoManager:FetchTimeWorked", data, cb)
end)

RegisterNUICallback("RenameCompany", function(data, cb)
	exports["pulsar-core"]:ServerCallback("Phone:CoManager:RenameCompany", data, cb)
end)

RegisterNUICallback("HireEmployee", function(data, cb)
	exports["pulsar-core"]:ServerCallback("Phone:CoManager:HireEmployee", data, cb)
end)

RegisterNUICallback("FireEmployee", function(data, cb)
	exports["pulsar-core"]:ServerCallback("Phone:CoManager:FireEmployee", data, cb)
end)

RegisterNUICallback("UpdateEmployee", function(data, cb)
	exports["pulsar-core"]:ServerCallback("Phone:CoManager:UpdateEmployee", data, cb)
end)

RegisterNUICallback("EditWorkplace", function(data, cb)
	exports["pulsar-core"]:ServerCallback("Phone:CoManager:EditWorkplace", data, cb)
end)

RegisterNUICallback("CreateGrade", function(data, cb)
	exports["pulsar-core"]:ServerCallback("Phone:CoManager:CreateGrade", data, cb)
end)

RegisterNUICallback("EditGrade", function(data, cb)
	exports["pulsar-core"]:ServerCallback("Phone:CoManager:EditGrade", data, cb)
end)

RegisterNUICallback("DeleteGrade", function(data, cb)
	exports["pulsar-core"]:ServerCallback("Phone:CoManager:DeleteGrade", data, cb)
end)

RegisterNUICallback("PurchaseUpgrade", function(data, cb)
	exports["pulsar-core"]:ServerCallback("Phone:CoManager:PurchaseUpgrade", data, cb)
end)

RegisterNUICallback("DisbandCompany", function(data, cb)
	exports["pulsar-core"]:ServerCallback("Phone:CoManager:DisbandCompany", data, cb)
end)

RegisterNUICallback("TransferCompany", function(data, cb)
	exports["pulsar-core"]:ServerCallback("Phone:CoManager:TransferCompany", data, cb)
end)
