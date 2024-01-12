function EnableSubmix(freqLow, freqHi, rmMix)
    SetAudioSubmixEffectRadioFx(0, 0)
    SetAudioSubmixEffectParamInt(0, 0, `default`, 1)
    SetAudioSubmixEffectParamFloat(0, 0, `freq_low`, freqLow)
    SetAudioSubmixEffectParamFloat(0, 0, `freq_hi`, freqHi)
    SetAudioSubmixEffectParamFloat(0, 0, `fudge`, 0.0)
    SetAudioSubmixEffectParamFloat(0, 0, `rm_mix`, rmMix)
end

function DisableSubmix()
    SetAudioSubmixEffectRadioFx(0, 0)
    SetAudioSubmixEffectParamInt(0, 0, `enabled`, 0)
end

function CalculateAudioParams(vehicleSpeed)
    local minSpeed = 0.0
    local maxSpeed = 50.0
    local minFreqLow = 0.0
    local maxFreqLow = 10.0
    local minFreqHi = 5000.0
    local maxFreqHi = 10000.0
    local minRmMix = 0.1
    local maxRmMix = 0.5

    local normalizedSpeed = math.min(math.max((vehicleSpeed - minSpeed) / (maxSpeed - minSpeed), 0.0), 1.0)

    local freqLow = minFreqLow + normalizedSpeed * (maxFreqLow - minFreqLow)
    local freqHi = minFreqHi + normalizedSpeed * (maxFreqHi - minFreqHi)
    local rmMix = minRmMix + normalizedSpeed * (maxRmMix - minRmMix)

    return freqLow, freqHi, rmMix
end

local soundmix = false
CreateThread(function()
    while true do
        Wait(500)
        local ped = PlayerPedId()

        if IsPedInAnyVehicle(ped, false) then
            local currentVehicle = GetVehiclePedIsIn(ped, false)
            local vehmodel = GetEntityModel(currentVehicle)

            if IsThisModelAHeli(vehmodel) or IsThisModelAPlane(vehmodel) then
                local speed = GetEntitySpeed(currentVehicle)

                if GetIsVehicleEngineRunning(currentVehicle) then
                    if not soundmix then
                        local freqLow, freqHi, rmMix = CalculateAudioParams(speed)
                        EnableSubmix(freqLow, freqHi, rmMix)
                        soundmix = true
                    end
                else
                    if soundmix then
                        DisableSubmix()
                        soundmix = false
                    end
                end
            else
                if soundmix then
                    DisableSubmix()
                    soundmix = false
                end
            end
        else
            if soundmix then
                DisableSubmix()
                soundmix = false
            end
        end
    end
end)
