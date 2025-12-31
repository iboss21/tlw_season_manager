# TLW Season Manager - Quick Reference

## 🚀 Quick Start Commands

```bash
# Installation
cd resources/[wolves]
git clone https://github.com/iboss21/tlw_season_manager.git
# Add to server.cfg: ensure tlw_season_manager
```

## 📋 Admin Commands

```
/season show          # Display current season status
/season set 8         # Set to Mid Summer (Peak Summer)
/season freeze on     # Stop automatic progression
/season freeze off    # Resume automatic progression
/season debug on      # Enable debug logging
/season ui            # Open NUI dashboard
/season help          # Show all commands
```

## 🔌 Export Examples

### Client-Side
```lua
-- Get current temperature for player location
local temp = exports['tlw_season_manager']:GetCurrentTemperature()
print('Current temperature: ' .. temp .. '°C')

-- Get season info
local state = exports['tlw_season_manager']:GetSeasonState()
print('Stage: ' .. state.stageName)
print('Weather: ' .. state.weather)

-- Get weather
local weather = exports['tlw_season_manager']:GetCurrentWeather()
if weather == 'snow' or weather == 'blizzard' then
    print('Winter conditions!')
end
```

### Server-Side
```lua
-- Set season stage
exports['tlw_season_manager']:SetStage(11) -- Mid Winter

-- Freeze progression
exports['tlw_season_manager']:FreezeStage(true)

-- Get all region temperatures
local temps = exports['tlw_season_manager']:GetAllRegionTemperatures()
for regionId, temp in pairs(temps) do
    print('Region ' .. regionId .. ': ' .. temp .. '°C')
end

-- Register a custom seasonal pack
exports['tlw_season_manager']:RegisterSeasonPack('my_halloween_pack', {
    name = 'Halloween Decorations',
    method = 'resource',
    enableStages = {9}, -- Late Autumn only
    autoStart = true
})
```

## 🎯 Integration Events

### Listen for Season Changes
```lua
-- Client
RegisterNetEvent('tlw_season_manager:client:stageChanged', function(data)
    print('Season changed to: ' .. data.stageName)
    -- Update your UI, adjust gameplay, etc.
end)

-- Server
AddEventHandler('tlw_season_manager:server:stageChanged', function(stageId, stageData)
    print('Server: Season changed to stage ' .. stageId)
    -- Trigger custom logic, update database, etc.
end)
```

### Listen for Weather Changes
```lua
RegisterNetEvent('tlw_season_manager:client:weatherChanged', function(data)
    print('Weather: ' .. data.weather .. ', Stability: ' .. data.stability)
    -- Adjust particle effects, lighting, etc.
end)
```

### Listen for Pack Toggles
```lua
RegisterNetEvent('tlw_season_manager:client:packToggled', function(resourceName, enabled)
    if resourceName == 'tlw_snowpack' then
        if enabled then
            print('Snow system enabled!')
        else
            print('Snow system disabled!')
        end
    end
end)
```

## ⚙️ Configuration Snippets

### Fast Progression (Testing)
```lua
Config.Seasons = {
    ProgressionMode = 'realtime',
    MinutesPerStage = 5,  -- 5 minutes per stage
    AutoAdvance = true
}
```

### Manual Control Only
```lua
Config.Seasons = {
    ProgressionMode = 'manual',
    AutoAdvance = false
}
```

### Disable Adjacency (Performance)
```lua
Config.Climate = {
    EnableAdjacency = false,  -- No region temperature bleed
    UpdateInterval = 120      -- Update every 2 minutes
}
```

### Add Custom Pack
```lua
Config.Packs.Registered = {
    ['my_custom_snow'] = {
        name = 'Custom Snow System',
        method = 'export',
        enableStages = {10, 11, 12},
        autoStart = true,
        exportFunction = 'ToggleSnow'  -- exports.my_custom_snow:ToggleSnow(true/false)
    }
}
```

## 🗺️ Region IDs

Quick reference for temperature queries:

| ID | Region | Zone |
|----|--------|------|
| 1-3 | Grizzlies | northern |
| 4-10 | Heartlands/New Hanover | central |
| 11-19 | Lemoyne/Bayou | southern |
| 20-25 | West Elizabeth | central/coastal |
| 26-33 | New Austin | desert |
| 34-38 | Special Locations | varies |

## 🌡️ Temperature Modifiers

```lua
-- Base temperature from stage (e.g., -10°C in Mid Winter)
+ Zone modifier (e.g., -8°C in northern regions)
+ Time of day (-3°C at night, +3°C at noon)
+ Solar gain (up to +4°C on clear days)
+ Evaporative cooling (up to -3.5°C in thunderstorms)
+ Snow cooling (-4°C to -6°C)
+ Insulation factor (+1.5°C at night with fog/clouds)
+ Adjacency bleed (±2°C from neighbors)
= Final Temperature
```

## 📊 Weather Transition Costs

Lower cost = easier transition:

```
Clear → Overcast: 1 (easy)
Clear → Rain: 4 (moderate)
Clear → Snow: 8 (hard)

Rain → Thunderstorm: 1 (easy)
Rain → Clear: 4 (moderate)

Thunderstorm → Rain: 1 (easy)
Thunderstorm → Clear: 6 (hard)
```

## 🔧 Troubleshooting

### "Weather not changing"
```lua
-- Check interval
Config.Weather.UpdateInterval = 300  -- seconds

-- Check stage not frozen
/season show  -- Look for "Frozen: No"

-- Force weather check
/season set X  -- Where X is current stage
```

### "Packs not starting"
```bash
# Verify resource exists
ensure tlw_snowpack

# Check console for pack manager logs
# Enable debug mode
/season debug on
```

### "Temperature seems wrong"
```lua
-- Check region detection
local coords = GetEntityCoords(PlayerPedId())
local region = Regions.GetByCoords(coords)
print('Region: ' .. region.name .. ', Zone: ' .. region.zone)

-- Verify time of day
local time = GetClockHours()
print('Hour: ' .. time)  -- Should affect temp
```

## 📈 Performance Tuning

```lua
-- Reduce update frequency
Config.Weather.UpdateInterval = 600  -- 10 minutes
Config.Climate.UpdateInterval = 120  -- 2 minutes

-- Disable adjacency if not needed
Config.Climate.EnableAdjacency = false

-- Limit active regions
Config.Climate.ActiveRegionDistance = 1000

-- Reduce NUI refresh rate
Config.NUI.RefreshInterval = 5000  -- 5 seconds
```

## 🎨 Custom Stage Example

Add a 13th stage (optional):

```lua
table.insert(Config.StageDefinitions, {
    id = 13,
    name = "Holiday Season",
    season = "winter",
    month = 12,
    description = "Festive winter period",
    baseTemp = -5,
    dailySwing = 6,
    weather = {
        clear = 0.30,
        overcast = 0.30,
        snow = 0.30,
        fog = 0.10
    },
    solarGain = 0.6,
    evaporativeCooling = 0.8,
    insulation = 1.2,
    packs = {'tlw_xmas_decorations', 'tlw_holiday_lights'}
})
```

## 📞 Support

- **Discord**: The Land of Wolves Server
- **GitHub**: [Issues](https://github.com/iboss21/tlw_season_manager/issues)
- **Website**: [wolves.land](https://wolves.land)

---

**Made with ❤️ by iBoss for The Land of Wolves** 🐺
