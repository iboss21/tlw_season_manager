-- TLW Season Manager - Server Main
-- Server-authoritative season state and sync

-- ============================================================================
-- STATE MANAGEMENT
-- ============================================================================

local SeasonState = {
    currentStage = Config.Seasons.StartingStage,
    currentDay = 1,
    currentWeather = 'clear',
    startTime = os.time(),
    lastWeatherChange = 0,
    frozen = false,
    initialized = false,
    
    -- Date provider state
    internalDate = Config.DateProvider.Internal.StartDate,
    
    -- Temperatures by region
    regionTemperatures = {},
    
    -- Transition state
    isTransitioning = false,
    transitionStartTime = 0,
    transitionProgress = 0
}

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

function InitializeSeasonManager()
    if SeasonState.initialized then return end
    
    Util.Log('==============================================')
    Util.Log('TLW Season Manager v1.0.0')
    Util.Log('The Land of Wolves - www.wolves.land')
    Util.Log('Developer: iBoss')
    Util.Log('==============================================')
    
    -- Load initial state
    LoadSeasonState()
    
    -- Initialize climate cache
    local stageData = GetCurrentStageData()
    Climate.UpdateTemperatureCache(stageData, SeasonState.currentWeather)
    SeasonState.regionTemperatures = Climate.GetAllRegionTemperatures()
    
    -- Start update loops
    StartSeasonLoop()
    StartWeatherLoop()
    StartClimateLoop()
    
    SeasonState.initialized = true
    
    Util.Log('Season Manager initialized successfully')
    Util.Log('Current Stage: ' .. stageData.name)
    Util.Log('Current Weather: ' .. SeasonState.currentWeather)
end

-- Load season state (from database/file in future)
function LoadSeasonState()
    -- For now, use config defaults
    SeasonState.currentStage = Config.Seasons.StartingStage
    SeasonState.currentDay = 1
    SeasonState.currentWeather = 'clear'
    SeasonState.frozen = not Config.Seasons.AutoAdvance
    
    Util.Debug('Season state loaded')
end

-- Save season state (for persistence)
function SaveSeasonState()
    -- TODO: Implement database/file persistence
    Util.Debug('Season state saved')
end

-- ============================================================================
-- SEASON STATE FUNCTIONS
-- ============================================================================

function GetCurrentStageData()
    local stage = Config.StageDefinitions[SeasonState.currentStage]
    if not stage then
        Util.Error('Invalid stage ID: ' .. SeasonState.currentStage)
        return Config.StageDefinitions[1]
    end
    return stage
end

function GetSeasonProgress()
    local totalStages = #Config.StageDefinitions
    local progress = (SeasonState.currentStage - 1) / totalStages
    return progress
end

function GetTimeUntilNextStage()
    if Config.Seasons.ProgressionMode == 'realtime' then
        local elapsed = os.time() - SeasonState.startTime
        local stageLength = Config.Seasons.MinutesPerStage * 60
        local remaining = stageLength - (elapsed % stageLength)
        return remaining
    elseif Config.Seasons.ProgressionMode == 'gametime' then
        local daysRemaining = Config.Seasons.DaysPerStage - SeasonState.currentDay
        return daysRemaining * Config.DateProvider.Internal.MinutesPerDay * 60
    else
        return -1 -- Manual mode
    end
end

-- ============================================================================
-- SEASON PROGRESSION
-- ============================================================================

function AdvanceStage()
    if SeasonState.frozen then
        Util.Debug('Stage advancement blocked: frozen')
        return
    end
    
    local oldStage = SeasonState.currentStage
    local oldStageData = GetCurrentStageData()
    
    -- Advance to next stage
    SeasonState.currentStage = SeasonState.currentStage + 1
    if SeasonState.currentStage > #Config.StageDefinitions then
        SeasonState.currentStage = 1
        Util.Log('Seasonal cycle completed, starting new year')
    end
    
    local newStageData = GetCurrentStageData()
    
    Util.Log('Stage advanced: ' .. oldStageData.name .. ' -> ' .. newStageData.name)
    
    -- Reset day counter
    SeasonState.currentDay = 1
    SeasonState.startTime = os.time()
    
    -- Start transition
    StartStageTransition(oldStage, SeasonState.currentStage)
    
    -- Trigger pack manager
    TriggerEvent('tlw_season_manager:server:stageChanged', SeasonState.currentStage, newStageData)
    
    -- Broadcast to clients
    TriggerClientEvent('tlw_season_manager:client:stageChanged', -1, {
        stage = SeasonState.currentStage,
        stageName = newStageData.name,
        description = newStageData.description,
        weather = SeasonState.currentWeather
    })
    
    -- Save state
    SaveSeasonState()
end

function StartStageTransition(fromStage, toStage)
    SeasonState.isTransitioning = true
    SeasonState.transitionStartTime = os.time()
    SeasonState.transitionProgress = 0
    
    Util.Debug('Started transition from stage ' .. fromStage .. ' to ' .. toStage)
end

function UpdateTransition()
    if not SeasonState.isTransitioning then return end
    
    local elapsed = os.time() - SeasonState.transitionStartTime
    SeasonState.transitionProgress = math.min(1.0, elapsed / Config.Seasons.TransitionDuration)
    
    if SeasonState.transitionProgress >= 1.0 then
        SeasonState.isTransitioning = false
        Util.Debug('Transition completed')
    end
end

-- ============================================================================
-- UPDATE LOOPS
-- ============================================================================

function StartSeasonLoop()
    CreateThread(function()
        while true do
            Wait(30000) -- Check every 30 seconds
            
            if not SeasonState.frozen and Config.Seasons.AutoAdvance then
                local remaining = GetTimeUntilNextStage()
                
                if remaining <= 0 then
                    AdvanceStage()
                end
                
                -- Update transition progress
                UpdateTransition()
            end
        end
    end)
    
    Util.Debug('Season loop started')
end

function StartWeatherLoop()
    CreateThread(function()
        while true do
            Wait(Config.Weather.UpdateInterval * 1000)
            
            local stageData = GetCurrentStageData()
            local newWeather, changed = Climate.DetermineNextWeather(
                SeasonState.currentWeather,
                stageData,
                SeasonState.lastWeatherChange
            )
            
            if changed then
                SeasonState.currentWeather = newWeather
                SeasonState.lastWeatherChange = os.time()
                
                Util.Log('Weather changed to: ' .. newWeather)
                
                -- Broadcast to clients
                TriggerClientEvent('tlw_season_manager:client:weatherChanged', -1, {
                    weather = newWeather,
                    stability = Climate.GetStabilityFactor(newWeather, stageData)
                })
            end
        end
    end)
    
    Util.Debug('Weather loop started')
end

function StartClimateLoop()
    CreateThread(function()
        while true do
            Wait(Config.Climate.UpdateInterval * 1000)
            
            local stageData = GetCurrentStageData()
            
            -- Add transition data if in transition
            if SeasonState.isTransitioning then
                local prevStage = SeasonState.currentStage - 1
                if prevStage < 1 then prevStage = #Config.StageDefinitions end
                
                stageData.transitionProgress = SeasonState.transitionProgress
                stageData.prevStageId = prevStage
                stageData.nextStageId = SeasonState.currentStage
            end
            
            -- Update temperature cache
            Climate.UpdateTemperatureCache(stageData, SeasonState.currentWeather)
            SeasonState.regionTemperatures = Climate.GetAllRegionTemperatures()
            
            Util.Debug('Climate updated - ' .. #SeasonState.regionTemperatures .. ' regions')
        end
    end)
    
    Util.Debug('Climate loop started')
end

-- ============================================================================
-- CLIENT SYNC
-- ============================================================================

RegisterNetEvent('tlw_season_manager:client:requestSync', function()
    local source = source
    local stageData = GetCurrentStageData()
    
    TriggerClientEvent('tlw_season_manager:client:sync', source, {
        stage = SeasonState.currentStage,
        stageName = stageData.name,
        description = stageData.description,
        weather = SeasonState.currentWeather,
        day = SeasonState.currentDay,
        frozen = SeasonState.frozen,
        temperatures = SeasonState.regionTemperatures,
        stability = Climate.GetStabilityFactor(SeasonState.currentWeather, stageData),
        progress = GetSeasonProgress(),
        timeUntilNext = GetTimeUntilNextStage()
    })
end)

-- ============================================================================
-- EXPORTS
-- ============================================================================

-- Get complete season state
exports('GetSeasonState', function()
    local stageData = GetCurrentStageData()
    return {
        stage = SeasonState.currentStage,
        stageName = stageData.name,
        description = stageData.description,
        season = stageData.season,
        weather = SeasonState.currentWeather,
        day = SeasonState.currentDay,
        frozen = SeasonState.frozen,
        temperatures = SeasonState.regionTemperatures,
        progress = GetSeasonProgress(),
        timeUntilNext = GetTimeUntilNextStage()
    }
end)

-- Get current stage
exports('GetCurrentStage', function()
    return SeasonState.currentStage, GetCurrentStageData()
end)

-- Get region temperature
exports('GetRegionTemperature', function(regionId)
    return Climate.GetCachedTemperature(regionId)
end)

-- Get all region temperatures
exports('GetAllRegionTemperatures', function()
    return SeasonState.regionTemperatures
end)

-- Get current weather
exports('GetCurrentWeather', function()
    return SeasonState.currentWeather
end)

-- Get stability factor
exports('GetStabilityFactor', function()
    local stageData = GetCurrentStageData()
    return Climate.GetStabilityFactor(SeasonState.currentWeather, stageData)
end)

-- Set stage (admin)
exports('SetStage', function(stageId)
    if stageId < 1 or stageId > #Config.StageDefinitions then
        return false
    end
    
    local oldStage = SeasonState.currentStage
    SeasonState.currentStage = stageId
    SeasonState.currentDay = 1
    SeasonState.startTime = os.time()
    
    StartStageTransition(oldStage, stageId)
    
    local stageData = GetCurrentStageData()
    Util.Log('Stage manually set to: ' .. stageData.name)
    
    -- Trigger events
    TriggerEvent('tlw_season_manager:server:stageChanged', stageId, stageData)
    TriggerClientEvent('tlw_season_manager:client:stageChanged', -1, {
        stage = stageId,
        stageName = stageData.name,
        description = stageData.description,
        weather = SeasonState.currentWeather
    })
    
    return true
end)

-- Freeze stage progression
exports('FreezeStage', function(freeze)
    SeasonState.frozen = freeze
    Util.Log('Stage progression ' .. (freeze and 'frozen' or 'unfrozen'))
    return true
end)

-- ============================================================================
-- STARTUP
-- ============================================================================

CreateThread(function()
    -- Wait for framework
    Wait(1000)
    
    -- Initialize
    InitializeSeasonManager()
end)
