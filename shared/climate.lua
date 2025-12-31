-- TLW Season Manager - Climate Engine
-- Handles temperature calculations, weather probabilities, and thermodynamic modifiers

Climate = {}

-- Cache for calculated temperatures
Climate.TemperatureCache = {}
Climate.LastUpdate = 0

-- ============================================================================
-- TEMPERATURE CALCULATION
-- ============================================================================

-- Calculate temperature for a specific region
function Climate.CalculateRegionTemperature(regionId, stageData, currentWeather, gameTime)
    local region = Regions.GetById(regionId)
    if not region then
        Util.Error('Invalid region ID: ' .. tostring(regionId))
        return 15 -- Default fallback
    end
    
    -- Get interpolated stage data
    local interpolatedData = Climate.GetInterpolatedStageData(stageData)
    
    -- Base temperature from stage
    local baseTemp = interpolatedData.baseTemp
    
    -- Regional zone modifier
    local zoneModifier = region.tempModifier or 0
    
    -- Time of day modifier (daily swing)
    local timeModifier = Climate.GetTimeOfDayModifier(gameTime, interpolatedData.dailySwing)
    
    -- Weather modifier (thermodynamic effects)
    local weatherModifier = Climate.GetWeatherModifier(currentWeather, interpolatedData)
    
    -- Spatial adjacency (IDW from neighbors)
    local adjacencyModifier = 0
    if Config.Climate.EnableAdjacency then
        adjacencyModifier = Climate.GetAdjacencyModifier(regionId)
    end
    
    -- Final temperature
    local finalTemp = baseTemp + zoneModifier + timeModifier + weatherModifier + adjacencyModifier
    
    return Util.Round(finalTemp, 1)
end

-- Get interpolated stage data for transitional stages
function Climate.GetInterpolatedStageData(currentStageData)
    -- If we have transition data, interpolate
    if currentStageData.transitionProgress then
        local progress = currentStageData.transitionProgress
        local prevStage = Config.StageDefinitions[currentStageData.prevStageId]
        local nextStage = Config.StageDefinitions[currentStageData.nextStageId]
        
        if prevStage and nextStage then
            return {
                baseTemp = Util.Lerp(prevStage.baseTemp, nextStage.baseTemp, progress),
                dailySwing = Util.Lerp(prevStage.dailySwing, nextStage.dailySwing, progress),
                solarGain = Util.Lerp(prevStage.solarGain, nextStage.solarGain, progress),
                evaporativeCooling = Util.Lerp(prevStage.evaporativeCooling, nextStage.evaporativeCooling, progress),
                insulation = Util.Lerp(prevStage.insulation, nextStage.insulation, progress)
            }
        end
    end
    
    -- No interpolation needed
    return {
        baseTemp = currentStageData.baseTemp,
        dailySwing = currentStageData.dailySwing,
        solarGain = currentStageData.solarGain,
        evaporativeCooling = currentStageData.evaporativeCooling,
        insulation = currentStageData.insulation
    }
end

-- Calculate time of day temperature modifier
function Climate.GetTimeOfDayModifier(gameTime, dailySwing)
    if not gameTime then
        gameTime = Util.GetGameTime()
    end
    
    local hour = gameTime.hour
    
    -- Use configured hourly modifiers
    local modifier = Config.Climate.HourlyModifiers[hour] or 0
    
    -- Scale by daily swing
    local scaled = modifier * (dailySwing / 10) -- Normalize to a 10-degree swing
    
    return scaled
end

-- Calculate weather-based temperature modifier (thermodynamics)
function Climate.GetWeatherModifier(weatherType, stageData)
    local modifier = 0
    
    -- Solar gain (clear/sunny weather adds heat)
    if Config.Climate.EnableSolarGain then
        if weatherType == 'clear' or weatherType == 'sunny' then
            local gameTime = Util.GetGameTime()
            local hour = gameTime.hour
            
            -- Solar gain peaks at midday
            if hour >= 10 and hour <= 16 then
                local solarStrength = (stageData.solarGain or 1.0)
                modifier = modifier + (2.0 * solarStrength)
            elseif hour >= 8 and hour <= 18 then
                local solarStrength = (stageData.solarGain or 1.0)
                modifier = modifier + (1.0 * solarStrength)
            end
        end
    end
    
    -- Evaporative cooling (rain/thunderstorm cools)
    if Config.Climate.EnableEvaporativeCooling then
        if weatherType == 'rain' or weatherType == 'drizzle' then
            local coolingFactor = (stageData.evaporativeCooling or 1.0)
            modifier = modifier - (2.0 * coolingFactor)
        elseif weatherType == 'thunderstorm' then
            local coolingFactor = (stageData.evaporativeCooling or 1.0)
            modifier = modifier - (3.5 * coolingFactor)
        end
    end
    
    -- Snow cooling
    if Config.Climate.EnableSnowCooling then
        if weatherType == 'snow' then
            modifier = modifier - 4.0
        elseif weatherType == 'blizzard' then
            modifier = modifier - 6.0
        end
    end
    
    -- Insulation (fog/overcast/snow traps heat at night, keeps cool in day)
    if Config.Climate.EnableInsulation then
        local gameTime = Util.GetGameTime()
        local hour = gameTime.hour
        local isNight = hour >= 20 or hour <= 6
        
        if weatherType == 'fog' or weatherType == 'overcast' or weatherType == 'snow' then
            local insulationFactor = (stageData.insulation or 1.0)
            
            if isNight then
                -- Trap heat at night
                modifier = modifier + (1.5 * insulationFactor)
            else
                -- Keep cooler during day
                modifier = modifier - (0.5 * insulationFactor)
            end
        end
    end
    
    return modifier
end

-- Calculate spatial adjacency modifier (IDW)
function Climate.GetAdjacencyModifier(regionId)
    -- Get cached temperatures of neighbors
    local neighbors = Regions.GetNeighborDistances(regionId)
    if #neighbors == 0 then return 0 end
    
    local dataPoints = {}
    for _, neighbor in ipairs(neighbors) do
        local neighborTemp = Climate.TemperatureCache[neighbor.region.id]
        if neighborTemp then
            table.insert(dataPoints, {
                value = neighborTemp,
                distance = neighbor.distance
            })
        end
    end
    
    if #dataPoints == 0 then return 0 end
    
    -- Calculate weighted average temperature difference
    local totalWeight = 0
    local weightedDiff = 0
    
    for _, point in ipairs(dataPoints) do
        local distance = math.max(point.distance, 100) -- Avoid division by zero
        local weight = 1 / (distance ^ 2)
        
        local currentTemp = Climate.TemperatureCache[regionId] or 15
        local tempDiff = point.value - currentTemp
        
        weightedDiff = weightedDiff + (tempDiff * weight)
        totalWeight = totalWeight + weight
    end
    
    if totalWeight == 0 then return 0 end
    
    local avgDiff = weightedDiff / totalWeight
    
    -- Apply adjacency weight from config
    local modifier = avgDiff * Config.Climate.AdjacencyWeight
    
    return modifier
end

-- ============================================================================
-- WEATHER SYSTEM
-- ============================================================================

-- Determine next weather type based on stage and persistence graph
function Climate.DetermineNextWeather(currentWeather, stageData, lastWeatherChange)
    local currentTime = os.time()
    
    -- Check minimum duration
    local minDuration = Config.Weather.MinimumDuration[currentWeather] or 300
    local timeSinceChange = currentTime - (lastWeatherChange or 0)
    
    if timeSinceChange < minDuration then
        -- Too soon to change
        return currentWeather, false
    end
    
    if not Config.Weather.UsePersistentGraph then
        -- Simple probability-based selection
        return Util.WeightedRandom(stageData.weather), true
    end
    
    -- Persistent graph with transition costs
    local transitionCosts = Config.Weather.TransitionCosts[currentWeather] or {}
    
    -- Calculate probabilities adjusted by transition costs
    local adjustedWeights = {}
    local totalWeight = 0
    
    for weatherType, baseProbability in pairs(stageData.weather) do
        if baseProbability > 0 then
            local transitionCost = transitionCosts[weatherType] or 5
            
            -- Lower cost = higher probability
            local adjustedProb = baseProbability / transitionCost
            adjustedWeights[weatherType] = adjustedProb
            totalWeight = totalWeight + adjustedProb
        end
    end
    
    -- Normalize
    for weatherType, _ in pairs(adjustedWeights) do
        adjustedWeights[weatherType] = adjustedWeights[weatherType] / totalWeight
    end
    
    -- Select new weather
    local newWeather = Util.WeightedRandom(adjustedWeights)
    
    return newWeather, (newWeather ~= currentWeather)
end

-- Calculate weather stability factor
function Climate.GetStabilityFactor(currentWeather, stageData)
    local baseStability = 1.0
    
    -- Insulation from current weather
    if currentWeather == 'fog' or currentWeather == 'overcast' or currentWeather == 'snow' then
        baseStability = baseStability * (stageData.insulation or 1.0)
    end
    
    -- Apply config multiplier
    baseStability = baseStability * Config.Weather.StabilityMultiplier
    
    return Util.Round(baseStability, 2)
end

-- ============================================================================
-- WEATHER PROBABILITIES
-- ============================================================================

-- Get weather probabilities for current stage
function Climate.GetWeatherProbabilities(stageId)
    local stage = Config.StageDefinitions[stageId]
    if not stage then return {} end
    
    return stage.weather
end

-- Get adjusted probabilities based on region
function Climate.GetRegionalWeatherProbabilities(stageId, regionId)
    local baseProbabilities = Climate.GetWeatherProbabilities(stageId)
    local region = Regions.GetById(regionId)
    if not region then return baseProbabilities end
    
    local zone = Regions.GetZone(region.zone)
    if not zone then return baseProbabilities end
    
    -- Adjust snow probability based on zone
    local adjusted = Util.TableCopy(baseProbabilities)
    
    if adjusted.snow then
        adjusted.snow = math.max(0, adjusted.snow + zone.snowModifier)
    end
    
    -- Normalize
    local total = 0
    for _, prob in pairs(adjusted) do
        total = total + prob
    end
    
    if total > 0 then
        for weather, prob in pairs(adjusted) do
            adjusted[weather] = prob / total
        end
    end
    
    return adjusted
end

-- ============================================================================
-- UPDATE CACHE
-- ============================================================================

-- Update temperature cache for all regions
function Climate.UpdateTemperatureCache(stageData, currentWeather)
    local gameTime = Util.GetGameTime()
    
    -- First pass: calculate base temperatures
    for _, region in ipairs(Regions.List) do
        Climate.TemperatureCache[region.id] = Climate.CalculateRegionTemperature(
            region.id,
            stageData,
            currentWeather,
            gameTime
        )
    end
    
    -- Second pass: apply adjacency (if enabled)
    if Config.Climate.EnableAdjacency then
        for _, region in ipairs(Regions.List) do
            local adjacencyMod = Climate.GetAdjacencyModifier(region.id)
            Climate.TemperatureCache[region.id] = Climate.TemperatureCache[region.id] + adjacencyMod
        end
    end
    
    Climate.LastUpdate = os.time()
end

-- Get cached temperature for a region
function Climate.GetCachedTemperature(regionId)
    return Climate.TemperatureCache[regionId] or 15
end

-- ============================================================================
-- EXPORTS
-- ============================================================================

-- Get all region temperatures
function Climate.GetAllRegionTemperatures()
    return Climate.TemperatureCache
end

return Climate
