-- TLW Season Manager - Utility Functions
-- Shared between client and server

Util = {}

-- Logging
function Util.Log(message, level)
    level = level or 'info'
    if Config.Debug or level == 'error' then
        local prefix = '[TLW Season Manager]'
        print(string.format('%s [%s] %s', prefix, string.upper(level), message))
    end
end

function Util.Debug(message)
    if Config.Debug then
        Util.Log(message, 'debug')
    end
end

function Util.Error(message)
    Util.Log(message, 'error')
end

-- Math utilities
function Util.Lerp(a, b, t)
    return a + (b - a) * math.max(0, math.min(1, t))
end

function Util.Clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

function Util.Round(value, decimals)
    decimals = decimals or 0
    local mult = 10 ^ decimals
    return math.floor(value * mult + 0.5) / mult
end

-- Table utilities
function Util.TableContains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

function Util.TableCopy(orig)
    local copy
    if type(orig) == 'table' then
        copy = {}
        for key, value in pairs(orig) do
            copy[key] = Util.TableCopy(value)
        end
    else
        copy = orig
    end
    return copy
end

function Util.TableMerge(t1, t2)
    for k, v in pairs(t2) do
        if type(v) == 'table' and type(t1[k]) == 'table' then
            Util.TableMerge(t1[k], v)
        else
            t1[k] = v
        end
    end
    return t1
end

-- String utilities
function Util.Trim(s)
    return s:match'^%s*(.*%S)' or ''
end

function Util.Split(str, delimiter)
    local result = {}
    local pattern = string.format("([^%s]+)", delimiter)
    str:gsub(pattern, function(c) result[#result+1] = c end)
    return result
end

function Util.Capitalize(str)
    return str:gsub("^%l", string.upper)
end

-- Distance calculation
function Util.GetDistance(coord1, coord2)
    local dx = coord1.x - coord2.x
    local dy = coord1.y - coord2.y
    local dz = coord1.z - coord2.z
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

function Util.GetDistance2D(coord1, coord2)
    local dx = coord1.x - coord2.x
    local dy = coord1.y - coord2.y
    return math.sqrt(dx * dx + dy * dy)
end

-- Time utilities
function Util.GetGameTime()
    local hour, minute, second
    
    -- Check if running on server or client
    if IsDuplicityVersion() then
        -- Server side: use real-world time
        local date = os.date("*t")
        hour = date.hour
        minute = date.min
        second = date.sec
    else
        -- Client side: use game clock
        hour = GetClockHours()
        minute = GetClockMinutes()
        second = GetClockSeconds()
    end
    
    return {
        hour = hour,
        minute = minute,
        second = second,
        totalHours = hour + minute / 60 + second / 3600
    }
end

function Util.GetServerTime()
    return os.time()
end

-- Format utilities
function Util.FormatTemperature(temp, decimals)
    decimals = decimals or 1
    return string.format('%.' .. decimals .. 'f°C', temp)
end

function Util.FormatDuration(seconds)
    local days = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    
    if days > 0 then
        return string.format('%dd %dh %dm', days, hours, minutes)
    elseif hours > 0 then
        return string.format('%dh %dm', hours, minutes)
    else
        return string.format('%dm', minutes)
    end
end

-- Weighted random selection
function Util.WeightedRandom(weights)
    local totalWeight = 0
    for _, weight in pairs(weights) do
        totalWeight = totalWeight + weight
    end
    
    local random = math.random() * totalWeight
    local cumulativeWeight = 0
    
    for key, weight in pairs(weights) do
        cumulativeWeight = cumulativeWeight + weight
        if random <= cumulativeWeight then
            return key
        end
    end
    
    -- Fallback (should never reach here)
    local firstKey = next(weights)
    return firstKey
end

-- Interpolation utilities
function Util.GetInterpolationFactors(currentStage, totalStages)
    -- Determine if we're in a peak or transitional stage
    local peakStages = {2, 5, 8, 11} -- Mid Spring, Mid Summer, Mid Autumn, Mid Winter
    
    local isPeak = Util.TableContains(peakStages, currentStage)
    
    if isPeak then
        -- 100% current stage
        return {{stage = currentStage, weight = 1.0}}
    else
        -- Transitional stage - blend with neighbors
        local prevPeak, nextPeak
        
        for i, peak in ipairs(peakStages) do
            if currentStage < peak then
                nextPeak = peak
                prevPeak = peakStages[i - 1] or peakStages[#peakStages]
                break
            end
        end
        
        if not nextPeak then
            nextPeak = peakStages[1]
            prevPeak = peakStages[#peakStages]
        end
        
        -- Calculate blend weight
        local distToPrev = math.abs(currentStage - prevPeak)
        local distToNext = math.abs(currentStage - nextPeak)
        if distToNext > 6 then distToNext = 12 - distToNext end
        if distToPrev > 6 then distToPrev = 12 - distToPrev end
        
        local total = distToPrev + distToNext
        local weightPrev = distToNext / total
        local weightNext = distToPrev / total
        
        return {
            {stage = prevPeak, weight = weightPrev},
            {stage = nextPeak, weight = weightNext}
        }
    end
end

-- IDW (Inverse Distance Weighting) for spatial interpolation
function Util.CalculateIDW(targetCoord, dataPoints, power)
    power = power or 2
    local numerator = 0
    local denominator = 0
    
    for _, point in ipairs(dataPoints) do
        local distance = Util.GetDistance(targetCoord, point.coord)
        
        if distance < 1 then
            -- If we're very close to a data point, just return its value
            return point.value
        end
        
        local weight = 1 / (distance ^ power)
        numerator = numerator + (weight * point.value)
        denominator = denominator + weight
    end
    
    if denominator == 0 then
        return 0
    end
    
    return numerator / denominator
end

return Util
