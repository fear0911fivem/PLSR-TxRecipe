-- Load scaleforms
exports("ScaleformLoadMovie", function(name)
	local scaleform = RequestScaleformMovie(name)
	while not HasScaleformMovieLoaded(scaleform) do
		Wait(0)
	end
	return scaleform
end)

exports("ScaleformLoadInteractive", function(name)
	local scaleform = RequestScaleformMovieInteractive(name)
	while not HasScaleformMovieLoaded(scaleform) do
		Wait(0)
	end
	return scaleform
end)

exports("ScaleformUnloadMovie", function(scaleform)
	SetScaleformMovieAsNoLongerNeeded(scaleform)
end)

-- Text & labels
exports("ScaleformLoadAdditionalText", function(gxt, count)
	for i = 0, count, 1 do
		if not HasThisAdditionalTextLoaded(gxt, i) then
			ClearAdditionalText(i, true)
			RequestAdditionalText(gxt, i)
			while not HasThisAdditionalTextLoaded(gxt, i) do
				Wait(0)
			end
		end
	end
end)

exports("ScaleformSetLabels", function(scaleform, labels)
	PushScaleformMovieFunction(scaleform, "SET_LABELS")
	for i = 1, #labels, 1 do
		local txt = labels[i]
		BeginTextCommandScaleformString(txt)
		EndTextCommandScaleformString()
	end
	PopScaleformMovieFunctionVoid()
end)

-- Push method vals wrappers
exports("ScaleformPopMulti", function(scaleform, method, ...)
	PushScaleformMovieFunction(scaleform, method)
	for _, v in pairs({ ... }) do
		local trueType = exports['pulsar-games']:ScaleformTrueType(v)
		if trueType == "string" then
			PushScaleformMovieFunctionParameterString(v)
		elseif trueType == "boolean" then
			PushScaleformMovieFunctionParameterBool(v)
		elseif trueType == "int" then
			PushScaleformMovieFunctionParameterInt(v)
		elseif trueType == "float" then
			PushScaleformMovieFunctionParameterFloat(v)
		end
	end
	PopScaleformMovieFunctionVoid()
end)

exports("ScaleformPopFloat", function(scaleform, method, val)
	PushScaleformMovieFunction(scaleform, method)
	PushScaleformMovieFunctionParameterFloat(val)
	PopScaleformMovieFunctionVoid()
end)

exports("ScaleformPopInt", function(scaleform, method, val)
	PushScaleformMovieFunction(scaleform, method)
	PushScaleformMovieFunctionParameterInt(val)
	PopScaleformMovieFunctionVoid()
end)

exports("ScaleformPopBool", function(scaleform, method, val)
	PushScaleformMovieFunction(scaleform, method)
	PushScaleformMovieFunctionParameterBool(val)
	PopScaleformMovieFunctionVoid()
end)

-- Push no args
exports("ScaleformPopRet", function(scaleform, method)
	PushScaleformMovieFunction(scaleform, method)
	return PopScaleformMovieFunction()
end)

exports("ScaleformPopVoid", function(scaleform, method)
	PushScaleformMovieFunction(scaleform, method)
	PopScaleformMovieFunctionVoid()
end)

-- Get return
exports("ScaleformRetBool", function(ret)
	return GetScaleformMovieFunctionReturnBool(ret)
end)

exports("ScaleformRetInt", function(ret)
	return GetScaleformMovieFunctionReturnInt(ret)
end)

-- Util functions
exports("ScaleformTrueType", function(val)
	if type(val) ~= "number" then
		return type(val)
	end

	local s = tostring(val)
	if string.find(s, ".") then
		return "float"
	else
		return "int"
	end
end)
