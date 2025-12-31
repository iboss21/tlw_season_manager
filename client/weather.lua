-- TLW Season Manager - Client Weather Handler
-- Applies weather changes using RDR3 natives

local CurrentWeatherType = 'sunny'
local IsTransitioning = false
local TransitionProgress = 0

-- Weather type mapping (RDR3 native weather types)
local WeatherTypeMap = {
    clear = 'sunny',
    overcast = 'overcast',
    fog = 'fog',
    drizzle = 'drizzle',
    rain = 'rain',
    thunderstorm = 'thunder',
    snow = 'snow',
    blizzard = 'blizzard',
    sunny = 'sunny'
}

-- ============================================================================
-- WEATHER APPLICATION
-- ============================================================================

function ApplyWeather(weatherType, instant)
    local nativeWeather = WeatherTypeMap[weatherType] or 'sunny'
    
    if instant then
        SetWeatherTypeNow(nativeWeather)
        Util.Debug('Applied weather instantly: ' .. nativeWeather)
    else
        -- Smooth transition
        SetWeatherTypeOvertimePersist(nativeWeather, 30.0) -- 30 second transition
        Util.Debug('Transitioning to weather: ' .. nativeWeather)
    end
    
    CurrentWeatherType = weatherType
end

-- Listen for weather changes
RegisterNetEvent('tlw_season_manager:client:weatherChanged', function(data)
    ApplyWeather(data.weather, false)
end)

-- Initial weather sync
CreateThread(function()
    Wait(5000) -- Wait for initial sync
    
    local state = exports['tlw_season_manager']:GetSeasonState()
    if state and state.weather then
        ApplyWeather(state.weather, true)
    end
end)

-- ============================================================================
-- WEATHER OVERRIDE PROTECTION
-- ============================================================================

-- Prevent other scripts from changing weather unexpectedly
if Config.Weather and Config.Weather.ProtectWeather then
    CreateThread(function()
        while true do
            Wait(5000)
            
            -- Verify weather hasn't been changed by another script
            local currentNativeWeather = GetWeatherType()
            local expectedNativeWeather = WeatherTypeMap[CurrentWeatherType]
            
            if currentNativeWeather ~= expectedNativeWeather and not IsTransitioning then
                Util.Debug('Weather override detected, reapplying: ' .. expectedNativeWeather)
                SetWeatherTypeOvertimePersist(expectedNativeWeather, 10.0)
            end
        end
    end)
end

Util.Debug('Client weather handler initialized')
