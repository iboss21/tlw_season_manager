# Season Manager - 12 Stage Dynamic Weather and Climate Overhaul

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/iboss21/tlw_season_manager)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![RDR2](https://img.shields.io/badge/game-Red%20Dead%20Redemption%202-red.svg)](https://www.nexusmods.com/reddeadredemption2/mods/7521)

Season Manager is a comprehensive immersion script that forces the world to follow a realistic 12-stage seasonal cycle. It features dynamic weather adjustments, temperature changes, and a complete climate overhaul for Red Dead Redemption 2.

## Features

### 🌍 12-Stage Seasonal Cycle
Experience a realistic progression through all four seasons with 12 distinct stages:

**Winter Stages (December - February)**
- **Deep Winter**: Coldest period with heavy snow and blizzards
- **Late Winter**: Still cold with occasional snow and fog
- **Winter's End**: Transition period with melting snow

**Spring Stages (March - May)**
- **Early Spring**: Warming temperatures with frequent rain
- **Mid Spring**: Pleasant temperatures with light showers
- **Late Spring**: Warm days with occasional thunderstorms

**Summer Stages (June - August)**
- **Early Summer**: Hot and humid with afternoon storms
- **Peak Summer**: Hottest period with heatwaves
- **Late Summer**: Still hot with gradual cooling

**Autumn Stages (September - November)**
- **Early Autumn**: Cooling temperatures and increased wind
- **Mid Autumn**: Crisp air with frequent rain and fog
- **Late Autumn**: First frosts with winter approaching

### ☁️ Dynamic Weather System
- Real-time weather changes based on current season stage
- Smooth transitions between weather types
- Season-appropriate weather patterns (snow in winter, thunderstorms in summer)
- Multiple weather types: clear, overcast, rain, snow, fog, thunderstorms, blizzards, heatwaves

### 🌡️ Temperature System
- Dynamic temperature calculations based on:
  - Current season stage
  - Time of day (warmer afternoons, colder nights)
  - Climate zone (mountains are colder, deserts are hotter)
- Realistic temperature ranges from -10°C to 32°C base temperatures
- Additional modifiers for location and time create authentic variations

### 🗺️ Climate Zone Overhaul
Five distinct climate zones with unique characteristics:

1. **Northern Mountain** (Grizzlies, Ambarino)
   - -8°C temperature modifier
   - Increased snow and wind
   
2. **Central Plains** (Heartlands, New Hanover)
   - Baseline temperatures
   - Moderate weather patterns

3. **Southern Humid** (Lemoyne, Bayou)
   - +5°C temperature modifier
   - Reduced snow, increased humidity

4. **Desert Arid** (New Austin, Rio Bravo)
   - +10°C temperature modifier
   - Minimal precipitation, increased wind

5. **Coastal Moderate** (Flat Iron Lake, coasts)
   - +2°C temperature modifier
   - Increased wind, moderate temperatures

## Installation

1. Download the latest release from [Nexus Mods](https://www.nexusmods.com/reddeadredemption2/mods/7521)
2. Extract the contents to your RDR2 scripts folder:
   ```
   Red Dead Redemption 2/scripts/
   ```
3. Ensure you have the required script hook installed (ScriptHook RDR2 or RedM)
4. Launch the game and the Season Manager will initialize automatically

## Configuration

Edit `config.json` to customize the mod:

```json
{
  "seasonManager": {
    "features": {
      "enableSeasonalCycle": true,
      "enableDynamicWeather": true,
      "enableTemperatureSystem": true,
      "enableClimateOverhaul": true
    },
    "seasonSettings": {
      "daysPerStage": 10,
      "startingStage": 1
    }
  }
}
```

### Configuration Options

- **daysPerStage**: Number of in-game days each stage lasts (default: 10)
- **startingStage**: Which stage to begin with (1-12)
- **transitionSpeed**: How quickly weather changes (0.0-1.0)
- **temperatureScale**: "celsius" or "fahrenheit"
- **enableLogging**: Enable debug logging for troubleshooting

## How It Works

### Seasonal Progression
Each of the 12 stages lasts for a configurable number of in-game days (default: 10). The complete cycle takes 120 in-game days, after which it loops back to stage 1.

### Weather Determination
Weather is determined probabilistically based on the current stage:
- Each stage has defined chances for snow, rain, and fog
- Remaining probability is distributed among stage-appropriate clear weather types
- Weather changes occur at random intervals with smooth transitions

### Temperature Calculation
Temperature is calculated using multiple factors:
```
Final Temperature = Base Temperature (from stage)
                  + Climate Zone Modifier
                  + Time of Day Variation
```

### Example Temperature Ranges
- **Deep Winter (Northern)**: -18°C to -3°C
- **Peak Summer (Desert)**: 37°C to 47°C
- **Mid Spring (Central)**: 12°C to 20°C

## API for Developers

The mod exports an API for integration with other scripts:

```lua
local SeasonManager = require("main")

-- Get current stage information
local stage = SeasonManager.API.GetCurrentStage()
print(stage.name)  -- e.g., "Deep Winter"

-- Get current temperature
local temp = SeasonManager.API.GetCurrentTemperature()

-- Get season progress (0.0 to 1.0)
local progress = SeasonManager.API.GetSeasonProgress()

-- Manually set stage (for testing)
SeasonManager.API.SetStage(8)  -- Jump to Peak Summer
```

## Compatibility

- **Game Version**: Red Dead Redemption 2 (PC)
- **Required**: Script Hook RDR2 or RedM framework
- **Conflicts**: May conflict with other weather/season mods
- **Performance**: Minimal impact (lightweight calculations)

## Troubleshooting

### Weather not changing
- Check that `enableDynamicWeather` is set to `true` in config.json
- Verify that no other weather mods are conflicting
- Enable debug logging to see weather change events

### Temperature seems incorrect
- Verify your climate zone is correctly detected
- Check the `temperatureScale` setting matches your preference
- Time of day significantly affects temperature

### Seasons not progressing
- Ensure `enableSeasonalCycle` is `true`
- Check that in-game time is actually advancing
- Try setting `debugMode` to `true` for detailed logging

## Roadmap

- [ ] Add more granular weather sub-types
- [ ] Implement wind direction and speed systems
- [ ] Add seasonal wildlife migration patterns
- [ ] Create UI overlay for season/weather information
- [ ] Add support for custom regional definitions
- [ ] Implement save/load functionality for season state

## Credits

- **Author**: iboss21
- **Nexus Mods**: [Season Manager](https://www.nexusmods.com/reddeadredemption2/mods/7521)
- **Community**: Thanks to all testers and contributors

## License

This mod is released under the MIT License. See LICENSE file for details.

## Support

- **Bug Reports**: [GitHub Issues](https://github.com/iboss21/tlw_season_manager/issues)
- **Nexus Mods**: [Mod Page](https://www.nexusmods.com/reddeadredemption2/mods/7521)
- **Discussions**: [GitHub Discussions](https://github.com/iboss21/tlw_season_manager/discussions)

## Changelog

### Version 1.0.0 (Initial Release)
- 12-stage seasonal cycle implementation
- Dynamic weather system with 10+ weather types
- Comprehensive temperature calculation system
- Climate zone overhaul with 5 distinct regions
- Configurable settings via JSON
- Full API for mod integration
- Debug mode for troubleshooting

---

**Enjoy your immersive seasonal experience in Red Dead Redemption 2!** 🎮🌲❄️🌸☀️🍂
