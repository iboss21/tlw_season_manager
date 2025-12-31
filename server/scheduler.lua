-- TLW Season Manager - Scheduler
-- Handles admin commands and time management

-- ============================================================================
-- ADMIN COMMANDS
-- ============================================================================

-- Main season command
Framework.RegisterCommand(Config.Commands.BaseCommand, function(source, args, rawCommand)
    local subCommand = args[1] and string.lower(args[1]) or 'show'
    
    if subCommand == Config.Commands.Show or subCommand == 'status' or subCommand == '' then
        -- Show current season status
        ShowSeasonStatus(source)
        
    elseif subCommand == Config.Commands.Set then
        -- Set stage
        local stageId = tonumber(args[2])
        if not stageId then
            Framework.Notify(source, 'Usage: /' .. Config.Commands.BaseCommand .. ' set <stage_id>', 'error')
            return
        end
        
        SetSeasonStage(source, stageId)
        
    elseif subCommand == Config.Commands.Freeze then
        -- Freeze/unfreeze progression
        local state = args[2] and string.lower(args[2])
        if state == 'on' or state == 'true' or state == '1' then
            FreezeSeasonProgression(source, true)
        elseif state == 'off' or state == 'false' or state == '0' then
            FreezeSeasonProgression(source, false)
        else
            Framework.Notify(source, 'Usage: /' .. Config.Commands.BaseCommand .. ' freeze on|off', 'error')
        end
        
    elseif subCommand == Config.Commands.Debug then
        -- Toggle debug mode
        local state = args[2] and string.lower(args[2])
        if state == 'on' or state == 'true' or state == '1' then
            Config.Debug = true
            Framework.Notify(source, 'Debug mode enabled', 'success')
        elseif state == 'off' or state == 'false' or state == '0' then
            Config.Debug = false
            Framework.Notify(source, 'Debug mode disabled', 'success')
        else
            Framework.Notify(source, 'Usage: /' .. Config.Commands.BaseCommand .. ' debug on|off', 'error')
        end
        
    elseif subCommand == Config.Commands.UI then
        -- Open UI
        TriggerClientEvent('tlw_season_manager:client:openUI', source)
        
    elseif subCommand == Config.Commands.Reload then
        -- Reload configuration
        ReloadConfiguration(source)
        
    elseif subCommand == 'help' then
        -- Show help
        ShowCommandHelp(source)
        
    else
        Framework.Notify(source, 'Unknown subcommand. Use /' .. Config.Commands.BaseCommand .. ' help', 'error')
    end
end, Config.Commands.AdminOnly)

-- ============================================================================
-- COMMAND FUNCTIONS
-- ============================================================================

function ShowSeasonStatus(source)
    local state = exports['tlw_season_manager']:GetSeasonState()
    local stageData = Config.StageDefinitions[state.stage]
    
    local messages = {
        '^3========== Season Manager Status ==========^0',
        '^2Current Stage:^0 ' .. state.stage .. '/12 - ' .. state.stageName,
        '^2Season:^0 ' .. stageData.season,
        '^2Description:^0 ' .. stageData.description,
        '^2Weather:^0 ' .. state.weather,
        '^2Day:^0 ' .. state.day,
        '^2Progress:^0 ' .. math.floor(state.progress * 100) .. '%',
        '^2Frozen:^0 ' .. (state.frozen and 'Yes' or 'No'),
        ''
    }
    
    if state.timeUntilNext > 0 then
        messages[#messages + 1] = '^2Next Stage In:^0 ' .. Util.FormatDuration(state.timeUntilNext)
    else
        messages[#messages + 1] = '^2Next Stage:^0 Manual progression only'
    end
    
    messages[#messages + 1] = '^3==========================================^0'
    
    for _, msg in ipairs(messages) do
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 255, 255},
            multiline = true,
            args = {msg}
        })
    end
end

function SetSeasonStage(source, stageId)
    if stageId < 1 or stageId > #Config.StageDefinitions then
        Framework.Notify(source, 'Invalid stage ID. Must be between 1 and ' .. #Config.StageDefinitions, 'error')
        return
    end
    
    local success = exports['tlw_season_manager']:SetStage(stageId)
    
    if success then
        local stageData = Config.StageDefinitions[stageId]
        Framework.Notify(source, 'Season stage set to: ' .. stageData.name, 'success')
        
        Util.Log('Admin ' .. GetPlayerName(source) .. ' set stage to ' .. stageData.name)
    else
        Framework.Notify(source, 'Failed to set season stage', 'error')
    end
end

function FreezeSeasonProgression(source, freeze)
    local success = exports['tlw_season_manager']:FreezeStage(freeze)
    
    if success then
        Framework.Notify(source, 'Season progression ' .. (freeze and 'frozen' or 'unfrozen'), 'success')
        Util.Log('Admin ' .. GetPlayerName(source) .. ' ' .. (freeze and 'froze' or 'unfroze') .. ' season progression')
    else
        Framework.Notify(source, 'Failed to change freeze state', 'error')
    end
end

function ReloadConfiguration(source)
    -- Reload config file
    -- Note: In production, this would need to actually reload the config
    Framework.Notify(source, 'Configuration reload not yet implemented', 'info')
    Util.Log('Admin ' .. GetPlayerName(source) .. ' attempted configuration reload')
end

function ShowCommandHelp(source)
    local messages = {
        '^3========== Season Manager Commands ==========^0',
        '^2/' .. Config.Commands.BaseCommand .. ' show^0 - Show current season status',
        '^2/' .. Config.Commands.BaseCommand .. ' set <stage>^0 - Set season stage (1-12)',
        '^2/' .. Config.Commands.BaseCommand .. ' freeze on|off^0 - Freeze/unfreeze progression',
        '^2/' .. Config.Commands.BaseCommand .. ' debug on|off^0 - Toggle debug mode',
        '^2/' .. Config.Commands.BaseCommand .. ' ui^0 - Open season dashboard',
        '^2/' .. Config.Commands.BaseCommand .. ' reload^0 - Reload configuration',
        '^2/' .. Config.Commands.BaseCommand .. ' help^0 - Show this help',
        '^3============================================^0'
    }
    
    for _, msg in ipairs(messages) do
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 255, 255},
            multiline = true,
            args = {msg}
        })
    end
end

-- ============================================================================
-- DATE PROVIDER MANAGEMENT
-- ============================================================================

function GetCurrentDate()
    if Config.DateProvider.Type == 'internal' then
        return GetInternalDate()
    elseif Config.DateProvider.Type == 'export' then
        return GetExternalDate()
    elseif Config.DateProvider.Type == 'txadmin' then
        return GetTxAdminDate()
    else
        return GetInternalDate() -- Fallback
    end
end

function GetInternalDate()
    -- Calculate date based on start date and elapsed time
    local elapsed = os.time() - SeasonState.startTime
    local minutesPerDay = Config.DateProvider.Internal.MinutesPerDay
    local daysPassed = math.floor(elapsed / (minutesPerDay * 60))
    
    -- Simple date calculation (not accounting for month lengths)
    local startDate = Config.DateProvider.Internal.StartDate
    local currentDay = startDate.day + daysPassed
    local currentMonth = startDate.month
    local currentYear = startDate.year
    
    -- Normalize (simple 30-day month approximation)
    while currentDay > 30 do
        currentDay = currentDay - 30
        currentMonth = currentMonth + 1
        
        if currentMonth > 12 then
            currentMonth = 1
            currentYear = currentYear + 1
        end
    end
    
    return {
        year = currentYear,
        month = currentMonth,
        day = currentDay
    }
end

function GetExternalDate()
    -- Try to get date from external resource
    local resource = Config.DateProvider.ExportResource
    local func = Config.DateProvider.ExportFunction
    
    if GetResourceState(resource) ~= 'started' then
        Util.Error('Date provider resource not found: ' .. resource)
        return GetInternalDate()
    end
    
    local success, result = pcall(function()
        return exports[resource][func]()
    end)
    
    if success and result then
        return result
    else
        Util.Error('Failed to get date from external provider')
        return GetInternalDate()
    end
end

function GetTxAdminDate()
    -- Map real-world date to in-game date
    -- This is a placeholder - actual implementation would depend on txAdmin integration
    local realDate = os.date('*t')
    
    return {
        year = 1899,
        month = realDate.month,
        day = realDate.day
    }
end

-- ============================================================================
-- SCHEDULED TASKS
-- ============================================================================

-- Auto-save state every 5 minutes
CreateThread(function()
    while true do
        Wait(300000) -- 5 minutes
        SaveSeasonState()
    end
end)

Util.Debug('Scheduler initialized')
