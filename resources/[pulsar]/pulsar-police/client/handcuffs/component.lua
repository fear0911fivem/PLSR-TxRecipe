_cuffPromise = nil

local MAX_CUFF_ATTEMPTS = 2

AddEventHandler('onClientResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Wait(1000)
		exports["pulsar-core"]:RegisterClientCallback("Handcuffs:VehCheck", function(data, cb)
			cb(IsPedInAnyVehicle(LocalPlayer.state.ped))
		end)

		exports["pulsar-core"]:RegisterClientCallback("Handcuffs:DoCuff", function(data, cb)
			if not IsPedInAnyVehicle(LocalPlayer.state.ped, true) then
				if _cuffPromise == nil then
					if not LocalPlayer.state.isCuffed then
						beingCuffedAnim(data.cuffer)
					end

					if data.isHardCuffed then
						_cuffFlags = 17
					else
						_cuffFlags = 49
					end

					if not data.forced and not LocalPlayer.state.isCuffed and not LocalPlayer.state.isDead then
						CuffAttempt()
						_cuffPromise = promise.new()
						exports['pulsar-games']:MinigamePlayRoundSkillbar(
							1.35 * math.ceil(((_attempts / 2) or 1)),
							(4 - (_attempts / 2) > 1 and 4 - (_attempts / 2) or 1),
							{
								onSuccess = "Handcuffs:Client:DoCuffBreak",
								onFail = "Handcuffs:Client:FailCuffBreak",
							},
							{
								animation = false,
							}
						)
						cb(Citizen.Await(_cuffPromise))
					else
						ResetTimer()
						cb(false)
						cuffAnim()
					end
				else
					cb(-1)
				end

				_cuffPromise = nil
			else
				cb(-1)
			end
		end)
	end
end)
