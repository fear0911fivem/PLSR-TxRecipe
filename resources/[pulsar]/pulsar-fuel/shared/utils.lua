function CalculateFuelCost(vehClass, amount)
    if amount > 0 and amount <= 100 then
        return exports['pulsar-core']:UtilsRound(math.abs(Config.FuelCost[vehClass] * amount), 0)
    end
    return false
end
