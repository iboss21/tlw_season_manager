-- TLW Season Manager - Client NUI Handler
-- Manages the NUI dashboard

local NUIOpen = false

-- ============================================================================
-- NUI CONTROL
-- ============================================================================

function OpenSeasonUI()
    if not Config.NUI or not Config.NUI.Enabled then
        Util.Error('NUI is disabled in configuration')
        return
    end
    
    SetNuiFocus(true, true)
    NUIOpen = true
    
    -- Send initial data
    UpdateNUIData()
    
    SendNUIMessage({
        type = 'show'
    })
    
    Util.Debug('NUI opened')
end

function CloseSeasonUI()
    SetNuiFocus(false, false)
    NUIOpen = false
    
    SendNUIMessage({
        type = 'hide'
    })
    
    Util.Debug('NUI closed')
end

function UpdateNUIData()
    if not NUIOpen then return end
    
    local state = exports['tlw_season_manager']:GetSeasonState()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local region, distance = Regions.GetByCoords(playerCoords)
    
    local data = {
        type = 'update',
        state = {
            stage = state.stage,
            stageName = state.stageName,
            description = state.description,
            weather = state.weather,
            day = state.day,
            frozen = state.frozen,
            stability = state.stability,
            progress = state.progress,
            timeUntilNext = state.timeUntilNext
        },
        region = {
            id = region and region.id or 0,
            name = region and region.name or 'Unknown',
            zone = region and region.zone or 'unknown',
            temperature = region and state.temperatures[region.id] or 15
        },
        temperatures = state.temperatures,
        config = {
            daysPerStage = Config.Seasons.DaysPerStage,
            stages = Config.StageDefinitions
        }
    }
    
    SendNUIMessage(data)
end

-- ============================================================================
-- EVENT HANDLERS
-- ============================================================================

RegisterNetEvent('tlw_season_manager:client:openUI', function()
    if NUIOpen then
        CloseSeasonUI()
    else
        OpenSeasonUI()
    end
end)

-- NUI Callbacks
RegisterNUICallback('close', function(data, cb)
    CloseSeasonUI()
    cb('ok')
end)

RegisterNUICallback('refresh', function(data, cb)
    UpdateNUIData()
    cb('ok')
end)

-- ============================================================================
-- KEY BINDING (if configured)
-- ============================================================================

if Config.NUI and Config.NUI.Keybind then
    RegisterCommand('+seasonui', function()
        if NUIOpen then
            CloseSeasonUI()
        else
            OpenSeasonUI()
        end
    end, false)
    
    RegisterCommand('-seasonui', function() end, false)
    
    RegisterKeyMapping('+seasonui', 'Toggle Season Manager UI', 'keyboard', Config.NUI.Keybind)
end

-- ============================================================================
-- AUTO UPDATE
-- ============================================================================

CreateThread(function()
    while true do
        Wait(Config.NUI and Config.NUI.RefreshInterval or 2000)
        
        if NUIOpen then
            UpdateNUIData()
        end
    end
end)

Util.Debug('Client NUI handler initialized')
