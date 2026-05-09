local DrillingSounds = {
	Playing = false,
	Sound = nil,
	PinSound = nil,
	FailSound = nil,
}

local DrillingPins = nil
local DrillingDisabledControls = { 30, 31, 32, 33, 34, 35 }

function loadModel(model)
	if IsModelInCdimage(model) then
		while not HasModelLoaded(model) do
			RequestModel(model)
			Wait(5)
		end
	end
end

function LoadAnim(dict)
	while not HasAnimDictLoaded(dict) do
		RequestAnimDict(dict)
		Wait(10)
	end
end

function DrillAnim()
	if
		DrillingSpeed <= 0
		and not IsEntityPlayingAnim(LocalPlayer.state.ped, "anim@heists@fleeca_bank@drilling", "drill_straight_idle", 3)
	then
		TaskPlayAnim(LocalPlayer.state.ped, "anim@heists@fleeca_bank@drilling", "drill_straight_idle", 8.0, 8.0, -1, 33)
	elseif
		DrillingSpeed > 0
		and not IsEntityPlayingAnim(
			LocalPlayer.state.ped,
			"anim@heists@fleeca_bank@drilling",
			"drill_straight_start",
			3
		)
	then
		TaskPlayAnim(
			LocalPlayer.state.ped,
			"anim@heists@fleeca_bank@drilling",
			"drill_straight_start",
			8.0,
			8.0,
			-1,
			33
		)
	end
end

function HandleDrillingFailure()
	local waitTime = math.random(5000, 10000)
	StopAnimTask(LocalPlayer.state.ped, "anim@heists@fleeca_bank@drilling", "drill_straight_start")
	StopAnimTask(LocalPlayer.state.ped, "anim@heists@fleeca_bank@drilling", "drill_straight_idle")
	Wait(50)
	TaskPlayAnim(
		LocalPlayer.state.ped,
		"anim@heists@fleeca_bank@drilling",
		"drill_straight_fail",
		8.0,
		8.0,
		waitTime,
		33
	)
	StopSound(DrillingSounds.Sound)

	PlaySoundFrontend(DrillingSounds.FailSound, "Drill_Jam", "DLC_HEIST_FLEECA_SOUNDSET", true)
	--ToggleDrillParticleFx( false, _drillPropHandle, ref _drillFx );
	Wait(waitTime)
	StopSound(DrillingSounds.FailSound)
end

function CreateAndAttachProp()
	loadModel(GetHashKey("hei_prop_heist_drill"))

	local myPos = GetEntityCoords(LocalPlayer.state.ped)
	local prop = CreateObject(GetHashKey("hei_prop_heist_drill"), myPos.x, myPos.y, myPos.z, true, false, false)
	FreezeEntityPosition(prop, true)
	SetEntityCollision(prop, false, false)

	AttachEntityToEntity(
		prop,
		LocalPlayer.state.ped,
		GetPedBoneIndex(LocalPlayer.state.ped, 28422),
		0,
		0,
		0,
		0,
		0,
		0,
		false,
		false,
		false,
		false,
		2,
		true
	)
	SetEntityInvincible(prop, true)

	SetModelAsNoLongerNeeded(GetHashKey("hei_prop_heist_drill"))

	DrillingProp = prop
end

local function DrillingInit()
	if DrillingScaleform then
		exports['pulsar-games']:ScaleformUnloadMovie(DrillingScaleform)
	end

	LoadAnim("anim@heists@fleeca_bank@drilling")
	DrillingScaleform = exports['pulsar-games']:ScaleformLoadMovie("DRILLING")

	DrillingSpeed = 0.0
	DrillingPos = 0.0
	DrillingTemp = 0.0
	DrillingHoleDepth = 0.0

	DrillingPins = {
		Pin1 = {
			Position = 0.325,
			Broken = false,
		},
		Pin2 = {
			Position = 0.475,
			Broken = false,
		},
		Pin3 = {
			Position = 0.625,
			Broken = false,
		},
		Pin4 = {
			Position = 0.775,
			Broken = false,
		},
	}

	DrillingSounds.Sound = GetSoundId()
	DrillingSounds.PinSound = GetSoundId()
	DrillingSounds.FailSound = GetSoundId()

	RequestAmbientAudioBank("HEIST_FLEECA_DRILL")
	RequestAmbientAudioBank("HEIST_FLEECA_DRILL_2")
	RequestAmbientAudioBank("DLC_MPHEIST\\HEIST_FLEECA_DRILL")
	RequestAmbientAudioBank("DLC_MPHEIST\\HEIST_FLEECA_DRILL_2")
	RequestAmbientAudioBank("SAFE_CRACK")
	RequestAmbientAudioBank("HUD_MINI_GAME_SOUNDSET")
	RequestAmbientAudioBank("dlc_heist_fleeca_bank_door_sounds")
	RequestAmbientAudioBank("vault_door")
	RequestAmbientAudioBank("DLC_HEIST_FLEECA_SOUNDSET")

	CreateAndAttachProp()

	exports['pulsar-games']:ScaleformPopFloat(DrillingScaleform, "SET_SPEED", 0.0)
	exports['pulsar-games']:ScaleformPopFloat(DrillingScaleform, "SET_DRILL_POSITION", 0.0)
	exports['pulsar-games']:ScaleformPopFloat(DrillingScaleform, "SET_TEMPERATURE", 0.0)
	exports['pulsar-games']:ScaleformPopFloat(DrillingScaleform, "SET_HOLE_DEPTH", 0.0)

	TaskPlayAnim(LocalPlayer.state.ped, "anim@heists@fleeca_bank@drilling", "drill_straight_idle", 8.0, 8.0, -1, 33)
end

local function DrillingUpdate(callback)
	FreezeEntityPosition(PlayerPedId(), true)
	while DrillingActive do
		exports['pulsar-games']:DrillingDraw()
		DrillAnim()
		--exports['pulsar-games']:DrillingDisableControls()

		for k, v in pairs(DrillingPins) do
			if not v.Broken and DrillingPos >= v.Position then
				PlaySoundFrontend(DrillingSounds.PinSound, "Drill_Pin_Break", "DLC_HEIST_FLEECA_SOUNDSET", true)
				DrillingPins[k].Broken = true
			end
		end

		if DrillingSpeed > 0 and DrillingSounds.Playing then
			SetVariableOnSound(DrillingSounds.Sound, "DrillState", 0)
		elseif DrillingSpeed > 0 and not DrillingSounds.Playing then
			PlaySoundFromEntity(
				DrillingSounds.Sound,
				"Drill",
				DrillingProp,
				"DLC_HEIST_FLEECA_SOUNDSET",
				false,
				0
			)
			DrillingSounds.Playing = true
		elseif DrillingSpeed <= 0 and DrillingSounds.Playing then
			StopSound(DrillingSounds.Sound)
			DrillingSounds.Playing = false
		end

		exports['pulsar-games']:DrillingHandleControls()

		Wait(0)
	end

	FreezeEntityPosition(PlayerPedId(), false)
	DeleteEntity(DrillingProp)
	DrillingProp = nil
	callback(DrillingResult)
end

exports("DrillingStart", function(callback)
	if not DrillingActive then
		DrillingActive = true
		DrillingInit()
		DrillingUpdate(callback)
	end
end)

exports("DrillingDraw", function()
	DrawScaleformMovieFullscreen(DrillingScaleform, 255, 255, 255, 255, 255)
end)

exports("DrillingHandleControls", function()
	local last_pos = DrillingPos
	if IsControlJustPressed(0, 32) then
		DrillingPos = math.min(1.0, DrillingPos + 0.01)
	elseif IsControlPressed(0, 32) then
		DrillingPos =
			math.min(1.0, DrillingPos + (0.1 * GetFrameTime() / (math.max(0.1, DrillingTemp) * 10)))
	elseif IsControlJustPressed(0, 33) then
		DrillingPos = math.max(0.0, DrillingPos - 0.01)
	elseif IsControlPressed(0, 33) then
		DrillingPos = math.max(0.0, DrillingPos - (0.1 * GetFrameTime()))
	end

	local last_speed = DrillingSpeed
	if IsControlJustPressed(0, 35) then
		DrillingSpeed = math.min(1.0, DrillingSpeed + 0.05)
	elseif IsControlPressed(0, 35) then
		DrillingSpeed = math.min(1.0, DrillingSpeed + (0.5 * GetFrameTime()))
	elseif IsControlJustPressed(0, 34) then
		DrillingSpeed = math.max(0.0, DrillingSpeed - 0.05)
	elseif IsControlPressed(0, 34) then
		DrillingSpeed = math.max(0.0, DrillingSpeed - (0.5 * GetFrameTime()))
	end

	if DrillingHoleDepth >= 0.1 and DrillingPos >= DrillingHoleDepth then
		SetVariableOnSound(DrillingSounds.Sound, "DrillState", 1.0)
	end

	local last_temp = DrillingTemp
	if last_pos < DrillingPos then
		if DrillingSpeed > 0.4 then
			if DrillingHoleDepth >= 0.1 and DrillingPos >= DrillingHoleDepth then
				DrillingTemp =
					math.min(1.0, DrillingTemp + ((0.05 * GetFrameTime()) * (DrillingSpeed * 10)))
			end
			exports['pulsar-games']:ScaleformPopFloat(DrillingScaleform, "SET_DRILL_POSITION", DrillingPos)
		else
			if DrillingPos < 0.1 or DrillingPos < DrillingHoleDepth then
				exports['pulsar-games']:ScaleformPopFloat(DrillingScaleform, "SET_DRILL_POSITION", DrillingPos)
			else
				if DrillingPos >= DrillingHoleDepth then
					DrillingTemp = math.min(1.0, DrillingTemp + (0.01 * GetFrameTime()))
				end
				DrillingPos = last_pos
			end
		end
	else
		if DrillingPos < DrillingHoleDepth then
			if DrillingPos < DrillingHoleDepth then
				DrillingTemp = math.max(
					0.0,
					DrillingTemp - ((0.05 * GetFrameTime()) * math.max(0.005, (DrillingSpeed * 10) / 2))
				)
			end
		end

		if DrillingPos ~= DrillingHoleDepth then
			exports['pulsar-games']:ScaleformPopFloat(DrillingScaleform, "SET_DRILL_POSITION", DrillingPos)
		end
	end

	if last_speed ~= DrillingSpeed then
		exports['pulsar-games']:ScaleformPopFloat(DrillingScaleform, "SET_SPEED", DrillingSpeed)
	end

	if last_temp ~= DrillingTemp then
		exports['pulsar-games']:ScaleformPopFloat(DrillingScaleform, "SET_TEMPERATURE", DrillingTemp)
	end

	if DrillingTemp >= 1.0 then
		HandleDrillingFailure()
		DrillingResult = false
		DrillingActive = false
	elseif DrillingPos >= 1.0 then
		StopSound(DrillingSounds.Sound)
		DrillingResult = true
		DrillingActive = false
	end

	DrillingHoleDepth = (DrillingPos > DrillingHoleDepth and DrillingPos or DrillingHoleDepth)
end)

exports("DrillingDisableControls", function()
	for _, control in ipairs(DrillingDisabledControls) do
		DisableControlAction(0, control, true)
	end
end)

exports("DrillingEnableControls", function()
	for _, control in ipairs(DrillingDisabledControls) do
		DisableControlAction(0, control, true)
	end
end)
