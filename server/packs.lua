-- TLW Season Manager - Seasonal Packs Manager
-- Handles automatic enabling/disabling of seasonal resource packs

local PackState = {
    registered = {},
    active = {},
    detected = {},
    initialized = false
}

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

function InitializePackManager()
    if PackState.initialized then return end
    
    Util.Log('Initializing Seasonal Pack Manager...')
    
    -- Detect available packs
    if Config.Packs.DetectOnStartup then
        DetectAvailablePacks()
    end
    
    -- Register configured packs
    RegisterConfiguredPacks()
    
    -- Listen for stage changes
    AddEventHandler('tlw_season_manager:server:stageChanged', function(stageId, stageData)
        OnStageChanged(stageId, stageData)
    end)
    
    PackState.initialized = true
    Util.Log('Seasonal Pack Manager initialized')
end

-- ============================================================================
-- PACK DETECTION
-- ============================================================================

function DetectAvailablePacks()
    PackState.detected = {}
    
    for resourceName, packConfig in pairs(Config.Packs.Registered) do
        local state = GetResourceState(resourceName)
        
        if state == 'started' or state == 'starting' then
            PackState.detected[resourceName] = {
                name = packConfig.name,
                state = state,
                available = true
            }
            Util.Debug('Detected pack: ' .. packConfig.name .. ' (' .. resourceName .. ')')
        elseif state == 'stopped' then
            PackState.detected[resourceName] = {
                name = packConfig.name,
                state = state,
                available = true
            }
            Util.Debug('Found stopped pack: ' .. packConfig.name .. ' (' .. resourceName .. ')')
        else
            if Config.Packs.LogMissing then
                Util.Log('Pack not found: ' .. packConfig.name .. ' (' .. resourceName .. ')', 'warn')
            end
        end
    end
    
    Util.Log('Detected ' .. CountTable(PackState.detected) .. ' available packs')
end

function CountTable(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

-- ============================================================================
-- PACK REGISTRATION
-- ============================================================================

function RegisterConfiguredPacks()
    for resourceName, packConfig in pairs(Config.Packs.Registered) do
        RegisterPack(resourceName, packConfig)
    end
end

function RegisterPack(resourceName, packConfig)
    PackState.registered[resourceName] = {
        name = packConfig.name,
        method = packConfig.method or Config.Packs.ManagementMethod,
        enableStages = packConfig.enableStages or {},
        autoStart = packConfig.autoStart ~= false,
        exportFunction = packConfig.exportFunction,
        eventName = packConfig.eventName,
        available = PackState.detected[resourceName] and PackState.detected[resourceName].available
    }
    
    Util.Debug('Registered pack: ' .. packConfig.name)
end

-- Export for external registration
exports('RegisterSeasonPack', function(resourceName, packConfig)
    RegisterPack(resourceName, packConfig)
    return true
end)

-- ============================================================================
-- STAGE CHANGE HANDLING
-- ============================================================================

function OnStageChanged(stageId, stageData)
    if not Config.Packs.AutoManage then
        Util.Debug('Pack auto-management disabled')
        return
    end
    
    Util.Log('Processing pack changes for stage: ' .. stageData.name)
    
    -- Delay to allow stage transition to settle
    CreateThread(function()
        Wait(Config.Packs.ToggleDelay * 1000)
        
        -- Check each registered pack
        for resourceName, packInfo in pairs(PackState.registered) do
            if packInfo.available and packInfo.autoStart then
                local shouldBeActive = ShouldPackBeActive(stageId, packInfo.enableStages)
                local isCurrentlyActive = PackState.active[resourceName]
                
                if shouldBeActive and not isCurrentlyActive then
                    -- Enable pack
                    EnablePack(resourceName, packInfo)
                elseif not shouldBeActive and isCurrentlyActive then
                    -- Disable pack
                    DisablePack(resourceName, packInfo)
                end
            end
        end
        
        -- Trigger pack update event
        TriggerEvent('tlw_season_manager:server:packsUpdated', PackState.active)
        TriggerClientEvent('tlw_season_manager:client:packsUpdated', -1, PackState.active)
    end)
end

function ShouldPackBeActive(currentStage, enableStages)
    if not enableStages or #enableStages == 0 then
        return false
    end
    
    for _, stageId in ipairs(enableStages) do
        if stageId == currentStage then
            return true
        end
    end
    
    return false
end

-- ============================================================================
-- PACK CONTROL
-- ============================================================================

function EnablePack(resourceName, packInfo)
    Util.Log('Enabling pack: ' .. packInfo.name .. ' (' .. resourceName .. ')')
    
    if packInfo.method == 'resource' then
        -- Start resource
        local state = GetResourceState(resourceName)
        
        if state == 'stopped' or state == 'missing' then
            local success = pcall(function()
                ExecuteCommand('ensure ' .. resourceName)
            end)
            
            if success then
                PackState.active[resourceName] = true
                Util.Log('Started resource: ' .. resourceName)
                
                -- Wait for resource to start
                CreateThread(function()
                    Wait(2000)
                    BroadcastPackChange(resourceName, true)
                end)
            else
                Util.Error('Failed to start resource: ' .. resourceName)
            end
        elseif state == 'started' or state == 'starting' then
            PackState.active[resourceName] = true
            Util.Debug('Resource already started: ' .. resourceName)
        end
        
    elseif packInfo.method == 'export' then
        -- Call export function
        if packInfo.exportFunction then
            local success = pcall(function()
                exports[resourceName][packInfo.exportFunction](true)
            end)
            
            if success then
                PackState.active[resourceName] = true
                Util.Log('Enabled pack via export: ' .. resourceName)
                BroadcastPackChange(resourceName, true)
            else
                Util.Error('Failed to call export on: ' .. resourceName)
            end
        end
        
    elseif packInfo.method == 'event' then
        -- Trigger event
        if packInfo.eventName then
            TriggerEvent(packInfo.eventName, true)
            PackState.active[resourceName] = true
            Util.Log('Enabled pack via event: ' .. resourceName)
            BroadcastPackChange(resourceName, true)
        end
    end
end

function DisablePack(resourceName, packInfo)
    Util.Log('Disabling pack: ' .. packInfo.name .. ' (' .. resourceName .. ')')
    
    if packInfo.method == 'resource' then
        -- Stop resource
        local state = GetResourceState(resourceName)
        
        if state == 'started' or state == 'starting' then
            local success = pcall(function()
                ExecuteCommand('stop ' .. resourceName)
            end)
            
            if success then
                PackState.active[resourceName] = false
                Util.Log('Stopped resource: ' .. resourceName)
                
                -- Wait for resource to stop
                CreateThread(function()
                    Wait(2000)
                    BroadcastPackChange(resourceName, false)
                end)
            else
                Util.Error('Failed to stop resource: ' .. resourceName)
            end
        else
            PackState.active[resourceName] = false
            Util.Debug('Resource already stopped: ' .. resourceName)
        end
        
    elseif packInfo.method == 'export' then
        -- Call export function
        if packInfo.exportFunction then
            local success = pcall(function()
                exports[resourceName][packInfo.exportFunction](false)
            end)
            
            if success then
                PackState.active[resourceName] = false
                Util.Log('Disabled pack via export: ' .. resourceName)
                BroadcastPackChange(resourceName, false)
            else
                Util.Error('Failed to call export on: ' .. resourceName)
            end
        end
        
    elseif packInfo.method == 'event' then
        -- Trigger event
        if packInfo.eventName then
            TriggerEvent(packInfo.eventName, false)
            PackState.active[resourceName] = false
            Util.Log('Disabled pack via event: ' .. resourceName)
            BroadcastPackChange(resourceName, false)
        end
    end
end

function BroadcastPackChange(resourceName, enabled)
    TriggerEvent('tlw_season_manager:server:packToggled', resourceName, enabled)
    TriggerClientEvent('tlw_season_manager:client:packToggled', -1, resourceName, enabled)
end

-- ============================================================================
-- EXPORTS
-- ============================================================================

-- Check if a pack is enabled
exports('IsPackEnabled', function(resourceName)
    return PackState.active[resourceName] == true
end)

-- Get all active packs
exports('GetActivePacks', function()
    local active = {}
    for resourceName, isActive in pairs(PackState.active) do
        if isActive then
            table.insert(active, {
                resourceName = resourceName,
                name = PackState.registered[resourceName] and PackState.registered[resourceName].name or resourceName
            })
        end
    end
    return active
end)

-- Get all registered packs
exports('GetRegisteredPacks', function()
    return PackState.registered
end)

-- Manually enable/disable a pack
exports('TogglePack', function(resourceName, enable)
    local packInfo = PackState.registered[resourceName]
    if not packInfo then
        return false, 'Pack not registered'
    end
    
    if enable then
        EnablePack(resourceName, packInfo)
    else
        DisablePack(resourceName, packInfo)
    end
    
    return true
end)

-- ============================================================================
-- STARTUP
-- ============================================================================

CreateThread(function()
    -- Wait for main system to initialize
    Wait(2000)
    
    InitializePackManager()
    
    -- Enable packs for current stage
    local currentStage = exports['tlw_season_manager']:GetCurrentStage()
    if currentStage then
        local stageData = Config.StageDefinitions[currentStage]
        if stageData then
            OnStageChanged(currentStage, stageData)
        end
    end
end)
