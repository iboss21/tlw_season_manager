# TLW Season Manager - 12 Stage Dynamic Weather and Climate Overhaul

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/iboss21/tlw_season_manager)
[![Framework](https://img.shields.io/badge/framework-LXRCore-green.svg)](https://github.com/lxrcore)
[![RedM](https://img.shields.io/badge/platform-RedM-red.svg)](https://redm.net)

**The Land of Wolves (www.wolves.land)** | **Developer: iBoss**

A comprehensive server-authoritative Season Manager for RedM that implements a realistic 12-stage seasonal cycle, advanced climate engine with thermodynamic calculations, and automatic seasonal resource pack management.

## 🌟 Overview

Season Manager is not just a weather script—it's a complete **seasonal controller and climate engine** designed for RedM servers. It manages:

- **12-Stage Seasonal Cycle** with automatic progression
- **Physics-Based Climate Engine** with temperature calculations
- **Persistent Weather Graphs** to prevent flicker
- **Automatic Pack Management** (snow systems, vegetation, decorations)
- **NUI Dashboard** for real-time monitoring
- **Multi-Framework Support** (LXRCore, RSG-Core, VORP, QBCore, Standalone)

## ✨ Key Features

### 🗓️ 12-Stage Seasonal Cycle
Progress through all four seasons with distinct stages:
- **Spring**: Early, Mid, Late Spring (warming, rain, storms)
- **Summer**: Early, Mid (Peak), Late Summer (hot, humid, heatwaves)
- **Autumn**: Early, Mid, Late Autumn (cooling, fog, frost)
- **Winter**: Early, Mid, Late Winter (cold, snow, blizzards)

### 🌡️ Advanced Climate Engine
**Thermodynamic Modifiers:**
- Solar gain (clear weather adds heat during daytime)
- Evaporative cooling (rain/storms cool the air)
- Snow cooling effects (freezing temperatures)
- Insulation factors (fog/clouds trap heat at night)

**Spatial Adjacency (IDW):**
- Cold air from Grizzlies bleeds into neighboring regions
- 38 regions with configurable neighbor graphs
- Weighted temperature blending

**Temporal Interpolation:**
- Transitional stages blend between peak seasons
- Smooth temperature and weather transitions
- No abrupt seasonal flips

### ☁️ Persistent Weather System
- Weather state machine with exit costs
- Prevents weather flicker (storm → rain → overcast → clear)
- Minimum duration enforcement
- Season-appropriate probabilities

### 📦 Automatic Pack Manager
Auto-enables/disables seasonal resources:
- `tlw_spring_vegetation` (stages 1-3)
- `tlw_extreme_grass` (stages 2-6)
- `tlw_autumn_vegetation` (stages 7-9)
- `tlw_snowpack` (stages 10-12)
- `tlw_xmas_decorations` (stage 11 only)

**Management Methods:**
- Start/stop resources
- Export function calls
- Event triggering

### 🖥️ NUI Dashboard
Beautiful infographic-style UI showing:
- Current season stage and progress
- Live weather and stability factor
- Regional temperature map
- Thermodynamic calculations
- 12-stage cycle visualization
- Debug data

## 🚀 Installation

1. **Download** the latest release
2. **Extract** to your RedM `resources` folder:
   ```
   resources/[wolves]/tlw_season_manager/
   ```
3. **Add** to `server.cfg`:
   ```cfg
   ensure tlw_season_manager
   ```
4. **Configure** `config.lua` (optional)
5. **Restart** server

## ⚙️ Configuration

### Basic Settings
```lua
Config.Seasons = {
    ProgressionMode = 'realtime',  -- 'realtime', 'gametime', or 'manual'
    MinutesPerStage = 1440,         -- 24 hours per stage (realtime)
    DaysPerStage = 10,              -- For gametime mode
    AutoAdvance = true,             -- Automatic progression
    StartingStage = 1               -- Begin at Early Spring
}
```

### Climate Engine
```lua
Config.Climate = {
    UpdateInterval = 60,            -- Temperature update (seconds)
    EnableAdjacency = true,         -- Region temperature bleed
    AdjacencyWeight = 0.3,          -- IDW influence (0.0-1.0)
    EnableSolarGain = true,         -- Solar heating
    EnableEvaporativeCooling = true, -- Rain cooling
    EnableSnowCooling = true,       -- Snow effects
    EnableInsulation = true         -- Cloud/fog insulation
}
```

### Framework Detection
```lua
Config.Framework = {
    Auto = true,                    -- Auto-detect framework
    Type = 'lxrcore'               -- Or 'rsg', 'vorp', 'qbcore', 'standalone'
}
```

## 🎮 Admin Commands

```
/season show          - Display current season status
/season set <1-12>    - Set season stage
/season freeze on|off - Freeze/unfreeze progression
/season debug on|off  - Toggle debug logging
/season ui            - Open NUI dashboard
/season reload        - Reload configuration
/season help          - Show command help
```

## 📊 The 12 Stages

| # | Stage | Season | Month | Temp | Weather Focus |
|---|-------|--------|-------|------|---------------|
| 1 | Early Spring | Spring | Mar | 8°C | Rain, drizzle |
| 2 | Mid Spring | Spring | Apr | 15°C | Sunny, showers |
| 3 | Late Spring | Spring | May | 20°C | Storms |
| 4 | Early Summer | Summer | Jun | 28°C | Hot, humid |
| 5 | Mid Summer | Summer | Jul | 32°C | Heatwaves |
| 6 | Late Summer | Summer | Aug | 28°C | Cooling begins |
| 7 | Early Autumn | Autumn | Sep | 20°C | Windy, rain |
| 8 | Mid Autumn | Autumn | Oct | 12°C | Fog, crisp |
| 9 | Late Autumn | Autumn | Nov | 3°C | First frost |
| 10 | Early Winter | Winter | Dec | -5°C | Snow |
| 11 | Mid Winter | Winter | Jan | -10°C | Blizzards |
| 12 | Late Winter | Winter | Feb | 0°C | Melting |

## 🗺️ Climate Zones

- **Northern Mountain**: Grizzlies, Ambarino (-8°C modifier)
- **Central Plains**: Heartlands, New Hanover (baseline)
- **Southern Humid**: Lemoyne, Bayou (+5°C modifier)
- **Desert Arid**: New Austin (+10°C modifier)
- **Coastal Moderate**: Flat Iron Lake (+2°C modifier)

## 🔌 Framework Support

### LXRCore (Primary)
```lua
local state = exports['tlw_season_manager']:GetSeasonState()
```

### RSG-Core
Automatic detection and adaptation

### VORP
Full compatibility with permissions

### QBCore
Export-based integration

### Standalone
Fallback mode with ace permissions

## 📡 Exports

### Client
```lua
-- Get season state
local state = exports['tlw_season_manager']:GetSeasonState()

-- Get current temperature
local temp = exports['tlw_season_manager']:GetCurrentTemperature()

-- Get region temperature
local regionTemp = exports['tlw_season_manager']:GetRegionTemperature(regionId)

-- Get current weather
local weather = exports['tlw_season_manager']:GetCurrentWeather()
```

### Server
```lua
-- Get season state
local state = exports['tlw_season_manager']:GetSeasonState()

-- Set stage (admin)
exports['tlw_season_manager']:SetStage(8) -- Jump to Mid Summer

-- Freeze progression
exports['tlw_season_manager']:FreezeStage(true)

-- Register custom pack
exports['tlw_season_manager']:RegisterSeasonPack('my_custom_pack', {
    name = 'My Custom Pack',
    method = 'resource',
    enableStages = {4, 5, 6},
    autoStart = true
})
```

## 📦 Pack Integration Contract

Your seasonal packs should respond to these events:

```lua
-- Stage changed event
AddEventHandler('tlw_season_manager:client:stageChanged', function(data)
    local stage = data.stage
    local stageName = data.stageName
    -- React to season change
end)

-- Pack toggled event
AddEventHandler('tlw_season_manager:client:packToggled', function(resourceName, enabled)
    if resourceName == GetCurrentResourceName() then
        -- Your pack was enabled/disabled
    end
end)
```

## 🧪 Testing

1. **Set Stage**: `/season set 11` (jump to Mid Winter)
2. **Open UI**: `/season ui` or press F10
3. **Check Logs**: `/season debug on`
4. **Freeze**: `/season freeze on` to stop progression

## 🛠️ Troubleshooting

### Weather not changing
- Check `Config.Weather.UpdateInterval` (default 300s)
- Ensure stage is not frozen: `/season show`
- Enable debug: `/season debug on`

### Packs not toggling
- Verify resource names in `Config.Packs.Registered`
- Check resource exists: `ensure <resource>`
- Review server console for pack manager logs

### Temperature issues
- Verify region definitions in `shared/regions.lua`
- Check adjacency is enabled
- Review thermodynamic modifiers in config

### Framework not detected
- Set `Config.Framework.Auto = false`
- Manually set `Config.Framework.Type`
- Ensure core resource is started

## 📈 Performance

- **Server**: ~0.02ms average tick
- **Client**: ~0.01ms average tick
- **Memory**: ~2MB server, ~1MB client
- **Network**: Minimal (sync every 60s)

## 🤝 Support & Community

- **Website**: [wolves.land](https://wolves.land)
- **Issues**: [GitHub Issues](https://github.com/iboss21/tlw_season_manager/issues)
- **Discord**: TLW Community Server

## 📜 License

MIT License - See [LICENSE](LICENSE) file

## 👏 Credits

- **Developer**: iBoss
- **Branding**: The Land of Wolves
- **Framework**: LXRCore Team
- **Community**: All TLW members and testers

---

**Transform your RedM server with realistic seasonal immersion!** 🎮🌲❄️🌸☀️🍂
