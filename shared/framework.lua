-- TLW Season Manager - Framework Adapter
-- Supports: LXRCore, RSG-Core, VORP, QBCore, Standalone

Framework = {}
Framework.Type = nil
Framework.Core = nil

-- Auto-detect framework
function Framework.Detect()
    if Config.Framework.Auto then
        -- Try to detect framework
        for fwType, resourceName in pairs(Config.Framework.Cores) do
            if GetResourceState(resourceName) == 'started' then
                Framework.Type = fwType
                Util.Log('Auto-detected framework: ' .. fwType)
                break
            end
        end
        
        if not Framework.Type then
            Framework.Type = 'standalone'
            Util.Log('No framework detected, using standalone mode')
        end
    else
        Framework.Type = Config.Framework.Type
        Util.Log('Using configured framework: ' .. Framework.Type)
    end
    
    -- Load the core
    Framework.LoadCore()
end

-- Load framework core
function Framework.LoadCore()
    if Framework.Type == 'lxrcore' then
        Framework.Core = exports['lxr-core']:GetCoreObject()
    elseif Framework.Type == 'rsg' then
        Framework.Core = exports['rsg-core']:GetCoreObject()
    elseif Framework.Type == 'vorp' then
        Framework.Core = exports.vorp_core:GetCore()
    elseif Framework.Type == 'qbcore' then
        Framework.Core = exports['qb-core']:GetCoreObject()
    else
        Framework.Core = nil
    end
    
    if Framework.Core then
        Util.Debug('Framework core loaded successfully')
    end
end

-- Check if player is admin
function Framework.IsAdmin(source)
    if Framework.Type == 'standalone' then
        return IsPlayerAceAllowed(source, 'command')
    end
    
    if Framework.Type == 'lxrcore' or Framework.Type == 'rsg' or Framework.Type == 'qbcore' then
        local Player = Framework.GetPlayer(source)
        if Player then
            local permission = Player.PlayerData.job.grade.level
            return permission >= 4 -- Admin level
        end
    elseif Framework.Type == 'vorp' then
        local User = Framework.Core.getUser(source)
        if User then
            return User.getGroup() == 'admin' or User.getGroup() == 'superadmin'
        end
    end
    
    return false
end

-- Get player object
function Framework.GetPlayer(source)
    if not Framework.Core then return nil end
    
    if Framework.Type == 'lxrcore' or Framework.Type == 'rsg' then
        return Framework.Core.Functions.GetPlayer(source)
    elseif Framework.Type == 'vorp' then
        return Framework.Core.getUser(source)
    elseif Framework.Type == 'qbcore' then
        return Framework.Core.Functions.GetPlayer(source)
    end
    
    return nil
end

-- Get player identifier
function Framework.GetIdentifier(source)
    if Framework.Type == 'lxrcore' or Framework.Type == 'rsg' or Framework.Type == 'qbcore' then
        local Player = Framework.GetPlayer(source)
        if Player then
            return Player.PlayerData.citizenid
        end
    elseif Framework.Type == 'vorp' then
        local User = Framework.GetPlayer(source)
        if User then
            return User.getIdentifier()
        end
    end
    
    -- Fallback to license
    for _, identifier in ipairs(GetPlayerIdentifiers(source)) do
        if string.find(identifier, 'license:') then
            return identifier
        end
    end
    
    return nil
end

-- Send notification to player
function Framework.Notify(source, message, type, duration)
    type = type or 'info'
    duration = duration or 5000
    
    if Framework.Type == 'lxrcore' or Framework.Type == 'rsg' then
        TriggerClientEvent('lxr-core:client:notify', source, {
            text = message,
            type = type,
            duration = duration
        })
    elseif Framework.Type == 'vorp' then
        TriggerClientEvent('vorp:TipRight', source, message, duration)
    elseif Framework.Type == 'qbcore' then
        TriggerClientEvent('QBCore:Notify', source, message, type, duration)
    else
        -- Standalone fallback
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 255, 255},
            multiline = true,
            args = {'Season Manager', message}
        })
    end
end

-- Register a command
function Framework.RegisterCommand(name, callback, adminOnly)
    adminOnly = adminOnly or false
    
    RegisterCommand(name, function(source, args, rawCommand)
        -- Check admin permission
        if adminOnly and not Framework.IsAdmin(source) then
            Framework.Notify(source, 'You do not have permission to use this command.', 'error')
            return
        end
        
        -- Execute callback
        callback(source, args, rawCommand)
    end, false)
    
    Util.Debug('Registered command: ' .. name)
end

-- Register a server event
function Framework.RegisterServerEvent(eventName, callback)
    RegisterNetEvent(eventName, function(...)
        callback(source, ...)
    end)
end

-- Trigger client event
function Framework.TriggerClientEvent(eventName, source, ...)
    TriggerClientEvent(eventName, source, ...)
end

-- Trigger server event (from client)
function Framework.TriggerServerEvent(eventName, ...)
    TriggerServerEvent(eventName, ...)
end

-- Get all players
function Framework.GetPlayers()
    return GetPlayers()
end

-- Get player coords (server-side)
function Framework.GetPlayerCoords(source)
    local ped = GetPlayerPed(source)
    if ped and DoesEntityExist(ped) then
        return GetEntityCoords(ped)
    end
    return nil
end

-- Initialize framework
if IsDuplicityVersion() then
    -- Server-side
    CreateThread(function()
        Framework.Detect()
    end)
else
    -- Client-side
    CreateThread(function()
        Framework.Detect()
    end)
end

return Framework
