-- TLW Season Manager - Client Main
-- Handles client-side state and sync

-- ============================================================================
-- CLIENT STATE
-- ============================================================================

local ClientState = {
    stage = 1,
    stageName = "Early Spring",
    description = "",
    weather = "clear",
    day = 1,
    frozen = false,
    temperatures = {},
    stability = 1.0,
    progress = 0,
    timeUntilNext = 0,
    synced = false
}

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

CreateThread(function()
    -- Wait for player to spawn
    while not NetworkIsPlayerActive(PlayerId()) do
        Wait(100)
    end
    
    -- Request initial sync
    RequestSync()
    
    Util.Log('Client initialized, season data synced')
end)

-- ============================================================================
-- SYNC HANDLING
-- ============================================================================

function RequestSync()
    TriggerServerEvent('tlw_season_manager:client:requestSync')
end

RegisterNetEvent('tlw_season_manager:client:sync', function(data)
    ClientState.stage = data.stage
    ClientState.stageName = data.stageName
    ClientState.description = data.description
    ClientState.weather = data.weather
    ClientState.day = data.day
    ClientState.frozen = data.frozen
    ClientState.temperatures = data.temperatures
    ClientState.stability = data.stability
    ClientState.progress = data.progress
    ClientState.timeUntilNext = data.timeUntilNext
    ClientState.synced = true
    
    Util.Debug('Client state synced: ' .. ClientState.stageName)
end)

-- ============================================================================
-- EVENT HANDLERS
-- ============================================================================

RegisterNetEvent('tlw_season_manager:client:stageChanged', function(data)
    ClientState.stage = data.stage
    ClientState.stageName = data.stageName
    ClientState.description = data.description
    ClientState.weather = data.weather
    
    Util.Log('Season changed to: ' .. data.stageName)
    
    -- Show notification
    if Config.NUI and Config.NUI.Enabled then
        SendNUIMessage({
            type = 'notification',
            title = 'Season Changed',
            message = 'Now entering: ' .. data.stageName,
            duration = 5000
        })
    end
end)

RegisterNetEvent('tlw_season_manager:client:weatherChanged', function(data)
    ClientState.weather = data.weather
    ClientState.stability = data.stability
    
    Util.Debug('Weather changed to: ' .. data.weather)
end)

RegisterNetEvent('tlw_season_manager:client:packsUpdated', function(activePacks)
    Util.Debug('Active packs updated')
end)

RegisterNetEvent('tlw_season_manager:client:packToggled', function(resourceName, enabled)
    Util.Debug('Pack ' .. resourceName .. ' ' .. (enabled and 'enabled' or 'disabled'))
end)

-- ============================================================================
-- EXPORTS
-- ============================================================================

-- Get current season state
exports('GetSeasonState', function()
    return ClientState
end)

-- Get current stage
exports('GetCurrentStage', function()
    return ClientState.stage, ClientState.stageName
end)

-- Get current weather
exports('GetCurrentWeather', function()
    return ClientState.weather
end)

-- Get current temperature for player's region
exports('GetCurrentTemperature', function()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local region, distance = Regions.GetByCoords(playerCoords)
    
    if region and ClientState.temperatures[region.id] then
        return ClientState.temperatures[region.id]
    end
    
    return 15 -- Default
end)

-- Get region temperature by ID
exports('GetRegionTemperature', function(regionId)
    return ClientState.temperatures[regionId] or 15
end)

-- Get stability factor
exports('GetStabilityFactor', function()
    return ClientState.stability
end)

-- Check if pack is enabled
exports('IsPackEnabled', function(packName)
    -- Query server
    local result = false
    TriggerServerEvent('tlw_season_manager:server:isPackEnabled', packName, function(enabled)
        result = enabled
    end)
    return result
end)

-- ============================================================================
-- PERIODIC SYNC
-- ============================================================================

-- Re-sync every 60 seconds
CreateThread(function()
    while true do
        Wait(60000)
        if ClientState.synced then
            RequestSync()
        end
    end
end)

Util.Debug('Client main initialized')
