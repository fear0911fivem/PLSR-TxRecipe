local _selling = {}
local _pendingLoanAccept = {}

local govCut = 5
local commissionCut = 5
local companyCut = 10

local _phoneApp = {
	color = '#136231',
	label = 'Dynasty 8',
	icon = 'house',
}

function RegisterCallbacks()
	exports["pulsar-core"]:RegisterServerCallback("Properties:RingDoorbell", function(source, data, cb)
		TriggerClientEvent("Properties:Client:Doorbell", -1, data)
		cb()
	end)

	exports["pulsar-core"]:RegisterServerCallback("Properties:RequestAgent", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local property = _properties[data]
		if char ~= nil and property ~= nil then
			for k, v in pairs(exports['pulsar-characters']:FetchAllCharacters()) do
				if v ~= nil then
					if exports['pulsar-jobs']:HasPermissionInJob(v:GetData("Source"), "realestate", "JOB_SELL") then
						exports['pulsar-phone']:EmailSend(
							v:GetData("Source"),
							char:GetData("Profiles").email.name,
							os.time(),
							"Requesting Agent",
							string.format(
								"Hello,<br /><br />I am interested in buying %s and would like to view the property.<br /><br />You can reach me at %s.<br /><br />Thanks!<br />- %s %s",
								property.label,
								char:GetData("Phone"),
								char:GetData("First"),
								char:GetData("Last")
							),
							{
								location = {
									x = property.location.front.x,
									y = property.location.front.y,
									z = property.location.front.z,
								},
							},
							(os.time() + (60 * 20))
						)
					end

					Wait(10)
				end
			end
			cb(true)
			return
		end
		cb(false)
	end)

	exports["pulsar-core"]:RegisterServerCallback("Properties:EditProperty", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local property = _properties[data.property]
		if property ~= nil and Player(source).state.onDuty == "realestate" and data.location then
			local ped = GetPlayerPed(source)
			local coords = GetEntityCoords(ped)
			local heading = GetEntityHeading(ped)

			if data.location == "garage" then
				local pos = {
					x = coords.x + 0.0,
					y = coords.y + 0.0,
					z = coords.z + 0.0,
					h = heading + 0.0
				}

				cb(exports['pulsar-properties']:AddGarage(data.property, pos))
			elseif data.location == "backdoor" then
				local pos = {
					x = coords.x + 0.0,
					y = coords.y + 0.0,
					z = coords.z - 1.2,
					h = heading + 0.0
				}

				cb(exports['pulsar-properties']:AddBackdoor(data.property, pos))
			else
				cb(false)
			end
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Properties:SpawnInside", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local property = _properties[data.id]
		if property ~= nil and char then
			local pInt = (property.upgrades and property.upgrades.interior)

			local routeId = exports["pulsar-core"]:RequestRouteId("Properties:" .. data.id, false)
			exports["pulsar-core"]:AddPlayerToRoute(source, routeId)
			GlobalState[string.format("%s:Property", source)] = data.id
			exports['pulsar-core']:MiddlewareTriggerEvent("Properties:Enter", source, data.id)

			if not _insideProperties[property.id] then
				_insideProperties[property.id] = {}
			end

			_insideProperties[property.id][source] = char:GetData("SID")

			local furniture = GetPropertyFurniture(property.id, pInt)

			TriggerLatentClientEvent("Properties:Client:InnerStuff", source, 50000, property, pInt, furniture)

			Player(source).state.tpLocation = (property.location and property.location.front)
		end
		cb(true)
	end)

	exports["pulsar-core"]:RegisterServerCallback("Properties:EnterProperty", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local property = _properties[data]

		if
			(property.keys ~= nil and property.keys[char:GetData("ID")])
			or (not property.sold and exports['pulsar-jobs']:HasPermissionInJob(source, "realestate", "JOB_DOORS"))
			or not property.locked or exports['pulsar-police']:IsInBreach(source, "property", data)
		then
			local pInt = (property.upgrades and property.upgrades.interior)

			exports['pulsar-pwnzor']:TempPosIgnore(source)
			local routeId = exports["pulsar-core"]:RequestRouteId("Properties:" .. data, false)
			exports["pulsar-core"]:AddPlayerToRoute(source, routeId)
			GlobalState[string.format("%s:Property", source)] = data
			exports['pulsar-core']:MiddlewareTriggerEvent("Properties:Enter", source, data)

			if not _insideProperties[property.id] then
				_insideProperties[property.id] = {}
			end

			_insideProperties[property.id][source] = char:GetData("SID")

			Player(source).state.tpLocation = (property.location and property.location.front)

			local furniture = GetPropertyFurniture(property.id, pInt)

			cb(true, property.id, pInt)
			TriggerLatentClientEvent("Properties:Client:InnerStuff", source, 50000, property, pInt, furniture)
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Properties:ExitProperty", function(source, data, cb)
		local property = GlobalState[string.format("%s:Property", source)]

		exports['pulsar-pwnzor']:TempPosIgnore(source)
		exports['pulsar-core']:MiddlewareTriggerEvent("Properties:Exit", source, property)
		exports["pulsar-core"]:RoutePlayerToGlobalRoute(source)
		GlobalState[string.format("%s:Property", source)] = nil

		if _insideProperties[property] then
			_insideProperties[property][source] = nil
		end

		Player(source).state.tpLocation = nil

		cb(property)
	end)

	exports["pulsar-core"]:RegisterServerCallback("Properties:ChangeLock", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local property = _properties[data.id]

		if
			(property.keys ~= nil and property.keys[char:GetData("ID")])
			or (not property.sold and exports['pulsar-jobs']:HasPermissionInJob(source, "realestate", "JOB_DOORS"))
		then
			cb(exports['pulsar-properties']:SetLock(data.id, data.state))
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Properties:Validate", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local property = _properties[data.id]

		if data.type == "closet" then
			cb(property.keys and property.keys[char:GetData("ID")] ~= nil)
		elseif data.type == "logout" then
			cb(property.keys and property.keys[char:GetData("ID")] ~= nil)
		elseif data.type == "stash" then
			if property.keys and property.keys[char:GetData("ID")] ~= nil and ((property.keys[char:GetData("ID")].Permissions and property.keys[char:GetData("ID")].Permissions.stash) or property.keys[char:GetData("ID")].Owner) and property.id or exports['pulsar-police']:IsInBreach(source, "property", property.id, true) then
				local interior = PropertyInteriors[property.upgrades.interior]
				local invType = 1000

				local capacity = false
				local slots = false

				if interior.inventoryOverride then
					invType = interior.inventoryOverride
				else
					local level = (property.upgrades and property.upgrades.storage) or 1
					if PropertyStorage[property.type] and PropertyStorage[property.type][level] then
						local storage = PropertyStorage[property.type][level]

						capacity = storage.capacity
						slots = storage.slots
					end
				end

				local invId = string.format("Property:%s", property.id)

				exports["pulsar-core"]:ClientCallback(source, "Inventory:Compartment:Open", {
					invType = invType,
					owner = invId,
				}, function()
					exports.ox_inventory:OpenSecondary(
						source,
						invType,
						invId,
						false,
						false,
						false,
						property.label,
						slots,
						capacity
					)
				end)
			end

			cb(true)
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Properties:Upgrade", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local property = _properties[data.id]

		if char and property.keys and property.keys[char:GetData("ID")] ~= nil and ((property.keys[char:GetData("ID")].Permissions and property.keys[char:GetData("ID")].Permissions.upgrade) or property.keys[char:GetData("ID")].Owner) then
			local propertyUpgrades = PropertyUpgrades[property.type]
			if propertyUpgrades then
				local thisUpgrade = propertyUpgrades[data.upgrade]
				if thisUpgrade then
					local currentLevel = exports['pulsar-properties']:UpgradeGet(property.id, data.upgrade)
					local nextLevel = thisUpgrade.levels[currentLevel + 1]
					local p = exports['pulsar-finance']:AccountsGetPersonal(char:GetData("SID"))
					if nextLevel and nextLevel.price and p and p.Account then
						local success = exports['pulsar-finance']:BalanceCharge(p.Account, nextLevel.price, {
							type = "bill",
							title = "Property Upgrade",
							description = string.format("Upgrade %s to Level %s on %s", thisUpgrade.name,
								currentLevel + 1, property.label),
							data = {
								property = property.id,
								upgrade = data.upgrade,
								level = currentLevel + 1,
							}
						})

						if success then
							local upgraded = exports['pulsar-properties']:UpgradeSet(property.id, data.upgrade,
								currentLevel + 1)
							if not upgraded then
								exports['pulsar-core']:LoggerError("Properties",
									string.format("SID %s Failed to Upgrade Property %s After Payment (%s - Level %s)",
										char:GetData("SID"), property.id, thisUpgrade.name, currentLevel + 1))
							end

							cb(upgraded)
							return
						end
					end
				end
			end
		end

		cb(false)
	end)

	local interiorChangeCost = 50000

	exports["pulsar-core"]:RegisterServerCallback("Properties:ChangeInterior", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local property = _properties[data.id]

		if char and data.int and property.keys and property.keys[char:GetData("ID")] ~= nil and ((property.keys[char:GetData("ID")].Permissions and property.keys[char:GetData("ID")].Permissions.upgrade) or property.keys[char:GetData("ID")].Owner) then
			local oldInterior = PropertyInteriors[(property.upgrades and property.upgrades.interior)]
			local newInterior = PropertyInteriors[data.int]
			local p = exports['pulsar-finance']:AccountsGetPersonal(char:GetData("SID"))

			if p and p.Account and oldInterior and newInterior and newInterior.type == property.type then
				local price = 0
				if oldInterior.price > newInterior.price then
					price = interiorChangeCost
				else
					price = interiorChangeCost + math.floor((newInterior.price or 0) - (oldInterior.price or 0))

					if price < 0 then
						price = 0
					end
				end

				local success = exports['pulsar-finance']:BalanceCharge(p.Account, price, {
					type = "bill",
					title = "Property Upgrade",
					description = string.format("Upgrade Interior to %s on %s",
						((newInterior.info and newInterior.info.name) or data.int),
						property.label),
					data = {
						property = property.id,
						upgrade = "interior",
						level = data.int,
					}
				})

				if success then
					local upgraded = exports['pulsar-properties']:UpgradeSetInterior(property.id, data.int)
					if not upgraded then
						exports['pulsar-core']:LoggerError("Properties",
							string.format("SID %s Failed to Upgrade Property %s After Payment (Interior - %s)",
								char:GetData("SID"), property.id, data.int))
					else
						DeletePropertyFurniture(property.id)
						exports['pulsar-properties']:ForceEveryoneLeave(property.id)
					end

					cb(upgraded)
					return
				end
			end
		end

		cb(false)
	end)

	exports["pulsar-core"]:RegisterServerCallback("Properties:Dyn8:Search", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char then
			local whereClause = "label LIKE ?"
			local params = { "%" .. data .. "%" }

			if Player(source).state.onDuty ~= 'realestate' then
				whereClause = whereClause .. " AND sold = 0"
			end

			exports.oxmysql:execute('SELECT * FROM properties WHERE ' .. whereClause .. ' LIMIT 80', params,
				function(results)
					if not results then
						cb(false)
						return
					end

					local convertedResults = {}
					for k, v in ipairs(results) do
						local property = {
							_id = v.id,
							id = v.id,
							type = v.type,
							label = v.label,
							price = v.price,
							sold = v.sold == 1,
							owner = v.owner,
							location = v.location and json.decode(v.location) or nil,
							upgrades = v.upgrades and json.decode(v.upgrades) or nil,
							locked = v.locked == 1,
							keys = v.keys and json.decode(v.keys) or nil,
							data = v.data and json.decode(v.data) or nil,
							foreclosed = v.foreclosed == 1,
							soldAt = v.soldAt
						}
						table.insert(convertedResults, property)
					end

					cb(convertedResults)
				end)
		else
			cb(false)
		end
	end)

	-- Hello

	exports["pulsar-core"]:RegisterServerCallback("Properties:Dyn8:Sell", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local prop = _properties[data.property]
		if Player(source).state.onDuty == 'realestate' then
			if prop ~= nil and not prop.sold and char then
				if _selling[data.property] == nil then
					local targetChar = exports['pulsar-characters']:FetchBySID(tonumber(data.target))
					if targetChar then
						_selling[data.property] = data.target

						if data.loan and data.time and data.deposit then
							local loanData = exports['pulsar-finance']:LoansGetAllowedLoanAmount(
								targetChar:GetData('SID'), 'property')
							local hasLoans = exports['pulsar-finance']:LoansGetPlayerLoans(targetChar:GetData('SID'),
								'property')
							local defaultInterestRate = exports['pulsar-finance']:LoansGetDefaultInterestRate()

							if #hasLoans <= 1 then
								if (loanData and loanData.maxBorrowable) and loanData.maxBorrowable > 0 and defaultInterestRate then
									local downPaymentPercent, loanWeeks = math.tointeger(data.deposit),
										math.tointeger(data.time)
									if downPaymentPercent and loanWeeks then
										local downPayment = exports['pulsar-core']:UtilsRound(
											prop.price * (downPaymentPercent / 100), 0)
										local salePriceAfterDown = prop.price - downPayment
										local afterInterest = exports['pulsar-core']:UtilsRound(
											salePriceAfterDown * (1 + (defaultInterestRate / 100)), 0)
										local perWeek = exports['pulsar-core']:UtilsRound(afterInterest / loanWeeks, 0)

										if loanData.maxBorrowable >= salePriceAfterDown then
											SendPendingLoanEmail({
													SID = targetChar:GetData('SID'),
													First = targetChar:GetData('First'),
													Last = targetChar:GetData('Last'),
													Source = targetChar:GetData('Source'),
												}, prop.label, downPaymentPercent, downPayment, loanWeeks, perWeek,
												salePriceAfterDown, function()
													exports['pulsar-finance']:BillingCreate(
														targetChar:GetData('Source'), 'Dynasty 8', downPayment,
														string.format('Property Downpayment for %s', prop.label),
														function(wasPayed, withAccount)
															if wasPayed then
																local loanSuccess = exports['pulsar-finance']
																	:LoansCreatePropertyLoan(
																		targetChar:GetData('Source'), prop.id, prop
																		.price,
																		downPayment, loanWeeks)
																if loanSuccess then
																	exports['pulsar-properties']:Buy(prop.id, {
																		Char = targetChar:GetData("ID"),
																		SID = targetChar:GetData("SID"),
																		First = targetChar:GetData("First"),
																		Last = targetChar:GetData("Last"),
																		Owner = true,
																	})

																	SendCompletedLoanSaleEmail({
																			Source = targetChar:GetData("Source"),
																			SID = targetChar:GetData("SID"),
																			First = targetChar:GetData("First"),
																			Last = targetChar:GetData("Last"),
																		}, prop.label, downPaymentPercent, downPayment,
																		loanWeeks,
																		perWeek, salePriceAfterDown)

																	-- Send Realtor Notification
																	exports['pulsar-phone']:NotificationAdd(source,
																		"Property Sale Successful",
																		string.format(
																			"(Loan Sale) %s was sold to %s %s.",
																			prop.label, targetChar:GetData('First'),
																			targetChar:GetData('Last')), os.time(), 7000,
																		_phoneApp, {})

																	SendPropertyProfits('Loan Sale', prop.price,
																		prop.label,
																		char:GetData('BankAccount'), withAccount, {
																			SID = targetChar:GetData("SID"),
																			First = targetChar:GetData("First"),
																			Last = targetChar:GetData("Last"),
																		})
																end
															else
																exports['pulsar-phone']:NotificationAdd(source,
																	"Property Sale Failed",
																	string.format(
																		"(Loan Sale) The downpayment failed when trying to sell %s to %s %s.",
																		prop.label, targetChar:GetData('First'),
																		targetChar:GetData('Last')), os.time(), 7000,
																	_phoneApp, {})
															end

															_selling[data.property] = nil
														end)
												end)
											cb({ success = true, message = 'Loan Offer Sent' })
										else
											cb({ success = false, message = 'Person Doesn\'t Qualify for Loan' })
										end
									end
								else
									cb({ success = false, message = 'Person Doesn\'t Qualify for Loan' })
								end
							else
								cb({ success = false, message = 'Person Doesn\'t Qualify for Loan' })
							end
						else
							cb({ success = true, message = 'Sale Offer Sent' })

							exports['pulsar-finance']:BillingCreate(targetChar:GetData('Source'), 'Dynasty 8',
								prop.price,
								'Purchase of ' .. prop.label, function(wasPayed, withAccount)
									if wasPayed then
										exports['pulsar-properties']:Buy(prop.id, {
											Char = targetChar:GetData("ID"),
											SID = targetChar:GetData("SID"),
											First = targetChar:GetData("First"),
											Last = targetChar:GetData("Last"),
											Owner = true,
										})

										-- Send Purchasee Confirmation
										SendCompletedCashSaleEmail({
											Source = targetChar:GetData("Source"),
											SID = targetChar:GetData("SID"),
											First = targetChar:GetData("First"),
											Last = targetChar:GetData("Last"),
										}, prop.label, prop.price)

										-- Send Realtor Confirmation
										exports['pulsar-phone']:NotificationAdd(source, "Property Sale Successful",
											string.format("(Cash Sale) %s was sold to %s %s.", prop.label,
												targetChar:GetData('First'), targetChar:GetData('Last')), os.time(), 7000,
											_phoneApp, {})

										SendPropertyProfits('Cash Sale', prop.price, prop.label,
											char:GetData('BankAccount'),
											withAccount, {
												SID = targetChar:GetData("SID"),
												First = targetChar:GetData("First"),
												Last = targetChar:GetData("Last"),
											})

										-- if prop.price >= 50000 then
										-- 	local creditIncrease = math.floor(prop.price / 1500)
										-- 	if creditIncrease > 300 then
										-- 		creditIncrease = 300
										-- 	end

										-- 	exports['pulsar-finance']:LoansCreditIncrease(targetChar:GetData('SID'), creditIncrease)
										-- end
									else
										exports['pulsar-phone']:NotificationAdd(source, "Property Sale Failed",
											string.format(
												"(Cash Sale) The bank transfer failed when trying to sell %s to %s %s.",
												prop.label, targetChar:GetData('First'), targetChar:GetData('Last')),
											os.time(), 7000, _phoneApp, {})
									end
									_selling[data.property] = nil
								end)
						end

						SetTimeout(5 * (60 * 1000), function()
							if _selling[data.property] then
								_selling[data.property] = nil
							end
						end)
					else
						cb({ success = false, message = 'Could Not Find State ID' })
					end
				else
					cb({ success = false, message = 'Property Already Being Sold' })
				end
			else
				cb({ success = false })
			end
		else
			cb({ success = false })
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Properties:Dyn8:CheckCredit", function(source, data, cb)
		local targetChar = exports['pulsar-characters']:FetchBySID(tonumber(data.target))
		if targetChar then
			local creditCheck = exports['pulsar-finance']:LoansGetAllowedLoanAmount(targetChar:GetData('SID'),
				'property')

			cb({
				SID = targetChar:GetData('SID'),
				price = creditCheck.maxBorrowable,
				score = creditCheck.creditScore,
				name = string.format('%s %s', targetChar:GetData('First'), targetChar:GetData('Last'))
			})
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Properties:Dyn8:Transfer", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local prop = _properties[data.property]
		if Player(source).state.onDuty == 'realestate' then
			if prop ~= nil and prop.sold and char then
				local owner = exports['pulsar-characters']:FetchBySID(prop.owner.SID)
				local newOwner = exports['pulsar-characters']:FetchBySID(tonumber(data.target))
				local hasLoan = exports['pulsar-finance']:LoansHasRemainingPayments("property", prop.id)

				if not hasLoan then
					if owner and newOwner then
						if newOwner:GetData("SID") ~= char:GetData("SID") then
							SendPendingPropertyTransfer(owner:GetData("Source"), true, {
								Property = prop.label,
								First = newOwner:GetData("First"),
								Last = newOwner:GetData("Last"),
								SID = newOwner:GetData("SID"),
							}, function(accepted, stateId)
								if accepted and stateId == owner:GetData("SID") then
									SendPendingPropertyTransfer(newOwner:GetData("Source"), false, {
										Property = prop.label,
										First = owner:GetData("First"),
										Last = owner:GetData("Last"),
										SID = owner:GetData("SID"),
									}, function(accepted, stateId)
										if accepted and stateId == newOwner:GetData("SID") then
											if exports['pulsar-properties']:Buy(prop.id, {
													Char = newOwner:GetData("ID"),
													SID = newOwner:GetData("SID"),
													First = newOwner:GetData("First"),
													Last = newOwner:GetData("Last"),
													Owner = true,
												}) then
												exports['pulsar-phone']:NotificationAdd(source,
													"Property Transfer Successful",
													"The property transfer was successful.", os.time(), 7000, _phoneApp,
													{})

												exports['pulsar-core']:LoggerWarn(
													"Properties",
													string.format(
														"Property %s (%s) Transfered From %s %s (%s) to %s %s (%s) By %s %s (%s)",
														prop.label,
														prop.id,
														owner:GetData("First"),
														owner:GetData("Last"),
														owner:GetData("SID"),
														newOwner:GetData("First"),
														newOwner:GetData("Last"),
														newOwner:GetData("SID"),
														char:GetData("First"),
														char:GetData("Last"),
														char:GetData("SID")
													)
												)
											else
												exports['pulsar-phone']:NotificationAdd(source,
													"Property Transfer Failed",
													"The property transfer failed.", os.time(), 7000, _phoneApp, {})
											end
										else
											exports['pulsar-phone']:NotificationAdd(source,
												"Property Transfer Failed",
												"The new owner declined the transfer.", os.time(), 7000, _phoneApp, {})
										end
									end)
								else
									exports['pulsar-phone']:NotificationAdd(source, "Property Transfer Failed",
										"The owner declined the transfer.", os.time(), 7000, _phoneApp, {})
								end
							end)

							cb({ success = true })
						else
							cb({ success = false, message = 'Cannot Transfer to Yourself' })
						end
					else
						cb({ success = false, message = 'Both the Owner & New Owner Need to Be Present' })
					end
				else
					cb({ success = false, message = 'Property still has a loan remaining' })
				end
			else
				cb({ success = false })
			end
		else
			cb({ success = false })
		end
	end)
end

local _pendingLoanAccept = {}

function SendPendingLoanEmail(charData, propertyLabel, downPaymentPercent, downPayment, loanWeeks, weeklyPayments,
							  remaining, cb)
	if not _pendingLoanAccept[charData.SID] then
		_pendingLoanAccept[charData.SID] = cb
		exports['pulsar-phone']:EmailSend(
			charData.Source,
			'loans@dynasty8.com',
			os.time(),
			string.format('Property Loan - %s', propertyLabel),
			string.format(
				[[
                    Dear %s %s,
                    Thank you for applying for a property loan for %s. The terms of this loan are set out below.<br><br>
                    Deposit: <b>$%s</b> (%s%%)<br>
                    Remaining Amount Owed: <b>$%s</b> (Interest Applied)<br>
                    Loan Length: <b>%s Weeks</b><br>
                    Weekly Payments: <b>$%s</b><br><br>

                    Missing loan payments will lead to an increase in the loans interest rate and a missed payment fee.
                    It may also lead to the eventual foreclosure of your property by the State of San Andreas.
                    <br><br>
                    If you agree with these terms, please click the link attached above to begin the loan acceptance process.
                    <br><br>
                    Thanks, Dynasty 8 Real Estate
                ]],
				charData.First,
				charData.Last,
				propertyLabel,
				formatNumberToCurrency(math.floor(downPayment)),
				downPaymentPercent,
				formatNumberToCurrency(math.floor(remaining)),
				loanWeeks,
				formatNumberToCurrency(math.floor(weeklyPayments))
			),
			{
				hyperlink = {
					event = 'RealEstate:Server:AcceptLoan',
				},
			},
			(os.time() + (60 * 5))
		)

		SetTimeout(60000 * 5, function()
			_pendingLoanAccept[charData.SID] = nil
		end)
	else
		cb(false, 1)
	end
end

RegisterNetEvent('RealEstate:Server:AcceptLoan', function(_, email)
	local src = source
	local char = exports['pulsar-characters']:FetchCharacterSource(src)
	if char then
		exports['pulsar-phone']:EmailDelete(char:GetData('ID'), email)
		local stateId = char:GetData('SID')

		if _pendingLoanAccept[stateId] then
			_pendingLoanAccept[stateId]()
			_pendingLoanAccept[stateId] = nil
		end
	end
end)

function SendCompletedLoanSaleEmail(charData, propertyLabel, downPaymentPercent, downPayment, loanWeeks, weeklyPayments,
									remaining)
	exports['pulsar-phone']:EmailSend(
		charData.Source,
		'loans@dynasty8.com',
		os.time(),
		string.format('Property Loan - %s', propertyLabel),
		string.format(
			[[
                Dear %s %s,
                Thank you for taking out a property loan for %s, it has been a pleasure doing business with you.
                <br><br>

                The terms of this loan are set out below.<br><br>
                Deposit: <b>$%s</b> (%s%%)<br>
                Remaining Amount Owed: <b>$%s</b> (Interest Applied)<br>
                Loan Length: <b>%s Weeks</b><br>
                Weekly Payments: <b>$%s</b><br><br>

                Missing loan payments will lead to an increase in the loans interest rate and a missed payment fee.
                It may also lead to the eventual foreclosure of your property by the State of San Andreas.
                <br><br>
                Thanks, Dynasty 8 Real Estate
            ]],
			charData.First,
			charData.Last,
			propertyLabel,
			formatNumberToCurrency(math.floor(downPayment)),
			downPaymentPercent,
			formatNumberToCurrency(math.floor(remaining)),
			loanWeeks,
			formatNumberToCurrency(math.floor(weeklyPayments))
		)
	)
end

function SendCompletedCashSaleEmail(charData, propertyLabel, price)
	exports['pulsar-phone']:EmailSend(
		charData.Source,
		'sales@dynasty8.com',
		os.time(),
		string.format('Property Purchase - %s', propertyLabel),
		string.format(
			[[
                Dear %s %s,
                We thank you for completing your purchase of <b>%s</b> for $%s, it has been a pleasure doing business with you.
                The Property Address is <b>%s</b><br>
                <br><br>
                Thanks, Dynasty 8 Real Estate
            ]],
			charData.First,
			charData.Last,
			propertyLabel,
			formatNumberToCurrency(math.floor(price)),
			propertyLabel
		),
		{}
	)
end

function SendPropertyProfits(type, propPrice, propLabel, playerBankAccount, payedAccount, buyerData)
	local dynastyAccount = exports['pulsar-finance']:AccountsGetOrganization('realestate')
	if dynastyAccount then
		exports['pulsar-finance']:BalanceDeposit(dynastyAccount.Account, math.floor(propPrice * (companyCut / 100)), {
			type = 'transfer',
			title = 'Property Purchase',
			description = string.format('Property %s - %s to %s %s (SID %s)', type, propLabel, buyerData.First,
				buyerData.Last, buyerData.SID),
			data = {
				property = propLabel,
				buyer = buyerData,
			},
		})
	end

	exports['pulsar-finance']:BalanceDeposit(playerBankAccount, math.floor(propPrice * (commissionCut / 100)), {
		type = 'transfer',
		title = 'Dynasty 8 - Property Sale Commission',
		description = string.format('Property %s - %s to %s %s (SID %s)', type, propLabel, buyerData.First,
			buyerData.Last, buyerData.SID),
		data = {
			property = propLabel,
			buyer = buyerData,
		},
	})

	exports['pulsar-finance']:BalanceDeposit(100000, math.floor(propPrice * (govCut / 100)), {
		type = 'transfer',
		title = 'Property Sales Tax',
		description = string.format('Property %s - %s to %s %s (SID %s)', type, propLabel, buyerData.First,
			buyerData.Last, buyerData.SID),
		data = {
			property = propLabel,
			buyer = buyerData,
		},
	})
end

local _pendingTransferAccept = {}

function SendPendingPropertyTransfer(source, isOwner, data, cb)
	_pendingTransferAccept[source] = cb

	local description = string.format("Transfer of %s from %s %s (%s)", data.Property, data.First, data.Last, data.SID)
	if isOwner then
		description = string.format("Transfer of %s to %s %s (%s)", data.Property, data.First, data.Last, data.SID)
	end

	exports['pulsar-phone']:NotificationAdd(source, "Property Transfer Request", description, os.time(), 15000,
		_phoneApp, {
			accept = "RealEstate:Client:AcceptTransfer",
			cancel = "RealEstate:Client:DenyTransfer",
		}, {
			data = data,
		})
end

RegisterNetEvent('RealEstate:Server:AcceptTransfer', function()
	local src = source
	local char = exports['pulsar-characters']:FetchCharacterSource(src)
	if char then
		local stateId = char:GetData('SID')

		if _pendingTransferAccept[src] then
			_pendingTransferAccept[src](true, stateId)
			_pendingTransferAccept[src] = nil
		end
	end
end)

RegisterNetEvent('RealEstate:Server:DenyTransfer', function()
	local src = source
	local char = exports['pulsar-characters']:FetchCharacterSource(src)
	if char then
		local stateId = char:GetData('SID')

		if _pendingTransferAccept[src] then
			_pendingTransferAccept[src](false, stateId)
			_pendingTransferAccept[src] = nil
		end
	end
end)

function formatNumberToCurrency(number)
	local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
	int = int:reverse():gsub("(%d%d%d)", "%1,")
	return minus .. int:reverse():gsub("^,", "") .. fraction
end
