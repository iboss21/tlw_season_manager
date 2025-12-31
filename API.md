# Season Manager API Reference

This document provides detailed information for developers who want to integrate with or extend the Season Manager mod.

## Table of Contents

- [Getting Started](#getting-started)
- [Core API Functions](#core-api-functions)
- [Data Structures](#data-structures)
- [Events and Hooks](#events-and-hooks)
- [Examples](#examples)
- [Best Practices](#best-practices)

## Getting Started

### Loading the Module

```lua
-- Load the Season Manager module
local SeasonManager = require("main")

-- Initialize if not already done
SeasonManager.Initialize()
```

### Basic Usage

```lua
-- Get current season information
local currentStage = SeasonManager.API.GetCurrentStage()
print("Current Season: " .. currentStage.name)
print("Base Temperature: " .. currentStage.baseTemperature .. "°C")

-- Get current temperature
local temp = SeasonManager.API.GetCurrentTemperature()
print("Current Temperature: " .. temp .. "°C")
```

## Core API Functions

### GetCurrentStage()

Returns the current season stage object with all its properties.

**Returns:** `table` - Season stage object

**Properties:**
- `name` (string) - Name of the stage (e.g., "Deep Winter")
- `month` (number) - Calendar month (1-12)
- `stage` (number) - Stage number (1-12)
- `description` (string) - Description of the stage
- `baseTemperature` (number) - Base temperature in Celsius
- `snowChance` (number) - Probability of snow (0.0-1.0)
- `rainChance` (number) - Probability of rain (0.0-1.0)
- `fogChance` (number) - Probability of fog (0.0-1.0)
- `windIntensity` (number) - Wind intensity (0.0-1.0)
- `weatherTypes` (table) - Array of possible weather types

**Example:**
```lua
local stage = SeasonManager.API.GetCurrentStage()
print(stage.name)           -- "Deep Winter"
print(stage.month)          -- 12
print(stage.baseTemperature) -- -10
print(stage.snowChance)     -- 0.8
```

### GetCurrentTemperature()

Returns the current calculated temperature based on season, time of day, and climate zone.

**Returns:** `number` - Temperature in Celsius (integer)

**Example:**
```lua
local temp = SeasonManager.API.GetCurrentTemperature()
if temp < 0 then
    print("It's freezing! Temperature: " .. temp .. "°C")
elseif temp > 30 then
    print("It's hot! Temperature: " .. temp .. "°C")
end
```

### GetCurrentWeather()

Returns the current active weather type.

**Returns:** `string` - Weather type identifier

**Possible Values:**
- `"clear_cold"` - Clear sky, cold temperatures
- `"clear_mild"` - Clear sky, moderate temperatures
- `"clear_warm"` - Clear sky, warm temperatures
- `"clear_hot"` - Clear sky, hot temperatures
- `"overcast"` - Cloudy but no precipitation
- `"fog"` - Foggy conditions
- `"rain"` - Light to moderate rain
- `"drizzle"` - Light rain
- `"thunderstorm"` - Heavy rain with thunder
- `"snow"` - Snowfall
- `"blizzard"` - Heavy snow with strong wind
- `"heatwave"` - Extremely hot conditions

**Example:**
```lua
local weather = SeasonManager.API.GetCurrentWeather()
if weather == "blizzard" then
    print("Warning: Blizzard conditions!")
elseif weather == "heatwave" then
    print("Warning: Extreme heat!")
end
```

### GetSeasonProgress()

Returns the progress through the current season stage as a normalized value.

**Returns:** `number` - Progress value between 0.0 and 1.0

**Example:**
```lua
local progress = SeasonManager.API.GetSeasonProgress()
local percentage = math.floor(progress * 100)
print("Season stage is " .. percentage .. "% complete")

if progress > 0.9 then
    print("Season transition coming soon!")
end
```

### SetStage(stageNumber)

Manually sets the season to a specific stage. Useful for testing or special events.

**Parameters:**
- `stageNumber` (number) - Stage number to set (1-12)

**Returns:** `boolean` - `true` if successful, `false` if invalid stage number

**Example:**
```lua
-- Jump to Peak Summer for testing
local success = SeasonManager.API.SetStage(8)
if success then
    print("Season changed to Peak Summer")
else
    print("Invalid stage number")
end
```

### GetAllStages()

Returns the complete array of all 12 season stages.

**Returns:** `table` - Array of all season stage objects

**Example:**
```lua
local allStages = SeasonManager.API.GetAllStages()
for i, stage in ipairs(allStages) do
    print(i .. ". " .. stage.name .. " (" .. stage.baseTemperature .. "°C)")
end
```

### GetConfig()

Returns the current configuration table.

**Returns:** `table` - Configuration object

**Example:**
```lua
local config = SeasonManager.API.GetConfig()
print("Days per stage: " .. config.daysPerStage)
print("Weather enabled: " .. tostring(config.enableDynamicWeather))

-- Modify config at runtime
config.weatherTransitionSpeed = 0.8
```

## Data Structures

### Season Stage Object

```lua
{
    name = "Deep Winter",
    month = 12,
    stage = 1,
    description = "Coldest period with heavy snow",
    baseTemperature = -10,
    snowChance = 0.8,
    rainChance = 0.1,
    fogChance = 0.3,
    windIntensity = 0.8,
    weatherTypes = {"snow", "blizzard", "overcast", "clear_cold"}
}
```

### Climate Zone Object

```lua
{
    name = "Northern Mountain",
    temperatureModifier = -8,
    snowModifier = 0.3,
    windModifier = 0.2,
    regions = {"Grizzlies West", "Grizzlies East", "Cumberland Forest"}
}
```

### Configuration Object

```lua
{
    enableSeasonalCycle = true,
    enableDynamicWeather = true,
    enableTemperatureSystem = true,
    enableClimateOverhaul = true,
    daysPerStage = 10,
    weatherTransitionSpeed = 0.5,
    temperatureTransitionSpeed = 0.3,
    debugMode = false
}
```

## Events and Hooks

While the current version doesn't expose event hooks directly, you can poll for changes:

### Detecting Season Changes

```lua
local lastStage = 0

function CheckSeasonChange()
    local currentStage = SeasonManager.API.GetCurrentStage()
    if currentStage.stage ~= lastStage then
        OnSeasonChanged(currentStage)
        lastStage = currentStage.stage
    end
end

function OnSeasonChanged(newStage)
    print("Season changed to: " .. newStage.name)
    -- Your custom logic here
end
```

### Detecting Weather Changes

```lua
local lastWeather = ""

function CheckWeatherChange()
    local currentWeather = SeasonManager.API.GetCurrentWeather()
    if currentWeather ~= lastWeather then
        OnWeatherChanged(currentWeather, lastWeather)
        lastWeather = currentWeather
    end
end

function OnWeatherChanged(newWeather, oldWeather)
    print("Weather changed from " .. oldWeather .. " to " .. newWeather)
    -- Your custom logic here
end
```

## Examples

### Example 1: Seasonal NPC Dialogue

```lua
local SeasonManager = require("main")

function GetSeasonalGreeting()
    local stage = SeasonManager.API.GetCurrentStage()
    local temp = SeasonManager.API.GetCurrentTemperature()
    
    if stage.stage >= 1 and stage.stage <= 3 then
        -- Winter
        if temp < -5 then
            return "Brrr, it's freezing out there!"
        else
            return "Cold day, isn't it?"
        end
    elseif stage.stage >= 4 and stage.stage <= 6 then
        -- Spring
        return "Beautiful spring day!"
    elseif stage.stage >= 7 and stage.stage <= 9 then
        -- Summer
        if temp > 30 then
            return "It's scorching hot today!"
        else
            return "Nice summer weather!"
        end
    else
        -- Autumn
        return "The leaves are beautiful this time of year."
    end
end
```

### Example 2: Dynamic Clothing System

```lua
local SeasonManager = require("main")

function GetRecommendedClothing()
    local temp = SeasonManager.API.GetCurrentTemperature()
    local weather = SeasonManager.API.GetCurrentWeather()
    
    local outfit = {
        layers = 0,
        coat = false,
        hat = false,
        gloves = false
    }
    
    -- Temperature-based
    if temp < 0 then
        outfit.layers = 3
        outfit.coat = true
        outfit.gloves = true
    elseif temp < 10 then
        outfit.layers = 2
        outfit.coat = true
    elseif temp < 20 then
        outfit.layers = 1
    else
        outfit.layers = 0
    end
    
    -- Weather-based
    if weather == "rain" or weather == "thunderstorm" then
        outfit.hat = true
    elseif weather == "snow" or weather == "blizzard" then
        outfit.hat = true
        outfit.gloves = true
    end
    
    return outfit
end
```

### Example 3: Seasonal Wildlife Spawning

```lua
local SeasonManager = require("main")

function ShouldSpawnWildlife(animalType)
    local stage = SeasonManager.API.GetCurrentStage()
    
    -- Bears hibernate in deep winter
    if animalType == "bear" and stage.stage == 1 then
        return false
    end
    
    -- Migratory birds only in spring/summer
    if animalType == "migratory_bird" then
        return stage.stage >= 4 and stage.stage <= 9
    end
    
    -- Deer are more common in autumn
    if animalType == "deer" and stage.stage >= 10 and stage.stage <= 12 then
        return math.random() < 0.8  -- 80% spawn chance
    end
    
    return true  -- Default: allow spawn
end
```

### Example 4: Temperature-Based Health Effects

```lua
local SeasonManager = require("main")

function ApplyTemperatureEffects(player)
    local temp = SeasonManager.API.GetCurrentTemperature()
    local weather = SeasonManager.API.GetCurrentWeather()
    
    -- Extreme cold
    if temp < -10 and (weather == "blizzard" or weather == "snow") then
        -- Apply frostbite effect
        player.health = player.health - 0.5
        print("Warning: Extreme cold! Take shelter!")
    end
    
    -- Extreme heat
    if temp > 35 and weather == "heatwave" then
        -- Apply heat exhaustion
        player.stamina = player.stamina - 0.3
        print("Warning: Extreme heat! Find shade and water!")
    end
    
    -- Comfortable temperature
    if temp >= 15 and temp <= 25 then
        -- Slight health regeneration bonus
        player.healthRegen = player.healthRegen * 1.1
    end
end
```

### Example 5: UI Display Integration

```lua
local SeasonManager = require("main")

function DrawSeasonUI()
    local stage = SeasonManager.API.GetCurrentStage()
    local temp = SeasonManager.API.GetCurrentTemperature()
    local weather = SeasonManager.API.GetCurrentWeather()
    local progress = SeasonManager.API.GetSeasonProgress()
    
    -- Draw season info (pseudo-code for UI)
    DrawText(10, 10, "Season: " .. stage.name)
    DrawText(10, 30, "Temperature: " .. temp .. "°C")
    DrawText(10, 50, "Weather: " .. weather)
    DrawProgressBar(10, 70, 200, 10, progress)
    DrawText(10, 85, "Stage Progress: " .. math.floor(progress * 100) .. "%")
end
```

## Best Practices

### 1. Check Initialization

Always ensure Season Manager is initialized before accessing the API:

```lua
local SeasonManager = require("main")
if not SeasonManager.API then
    print("Season Manager not initialized!")
    return
end
```

### 2. Cache API Calls

Don't call API functions every frame. Cache results and update periodically:

```lua
local cachedTemp = 0
local cacheTimer = 0
local CACHE_DURATION = 5  -- Update every 5 seconds

function UpdateWithCache(deltaTime)
    cacheTimer = cacheTimer + deltaTime
    
    if cacheTimer >= CACHE_DURATION then
        cachedTemp = SeasonManager.API.GetCurrentTemperature()
        cacheTimer = 0
    end
    
    -- Use cachedTemp in your logic
end
```

### 3. Handle Edge Cases

Always handle potential nil values or edge cases:

```lua
local stage = SeasonManager.API.GetCurrentStage()
if not stage or not stage.name then
    print("Error: Invalid stage data")
    return
end
```

### 4. Respect Configuration

Check if features are enabled before implementing dependent logic:

```lua
local config = SeasonManager.API.GetConfig()
if config.enableTemperatureSystem then
    -- Temperature-based logic
end
```

### 5. Use Stage Numbers for Logic

Use stage numbers for logic, names for display:

```lua
local stage = SeasonManager.API.GetCurrentStage()

-- For logic: use stage number
if stage.stage >= 1 and stage.stage <= 3 then
    -- Winter logic
end

-- For display: use name
print("Current season: " .. stage.name)
```

## Support

For questions or issues with the API:
- [GitHub Issues](https://github.com/iboss21/tlw_season_manager/issues)
- [Documentation](DOCUMENTATION.md)
- [Nexus Mods](https://www.nexusmods.com/reddeadredemption2/mods/7521)

---

**Happy modding! 🎮**
