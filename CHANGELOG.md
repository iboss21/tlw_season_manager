# Changelog

All notable changes to Season Manager will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-12-31

### Added
- Initial release of Season Manager
- 12-stage seasonal cycle system
  - Deep Winter, Late Winter, Winter's End
  - Early Spring, Mid Spring, Late Spring
  - Early Summer, Peak Summer, Late Summer
  - Early Autumn, Mid Autumn, Late Autumn
- Dynamic weather system
  - 10+ weather types (clear, rain, snow, fog, thunderstorm, blizzard, heatwave, etc.)
  - Season-appropriate weather patterns
  - Probabilistic weather determination based on current stage
- Temperature system
  - Base temperatures ranging from -10°C to 32°C
  - Time of day variations (8-degree swing)
  - Climate zone modifiers
- Climate zone overhaul
  - Northern Mountain zone (-8°C modifier)
  - Central Plains zone (baseline)
  - Southern Humid zone (+5°C modifier)
  - Desert Arid zone (+10°C modifier)
  - Coastal Moderate zone (+2°C modifier)
- Configuration system
  - JSON-based configuration file
  - Customizable season length (days per stage)
  - Adjustable weather transition speed
  - Temperature scale selection (Celsius/Fahrenheit)
  - Feature toggles for all major systems
- Developer API
  - GetCurrentStage() - Get current season information
  - GetCurrentTemperature() - Get calculated temperature
  - GetCurrentWeather() - Get active weather type
  - GetSeasonProgress() - Get progress through current stage
  - SetStage() - Manually change season (for testing)
- Documentation
  - Comprehensive README with feature overview
  - Detailed DOCUMENTATION.md with API reference
  - Step-by-step INSTALL.md guide
  - MIT License
- Metadata files
  - manifest.json with complete mod information
  - version.txt for version tracking

### Features
- Lightweight performance impact
- Smooth weather and temperature transitions
- Realistic seasonal progression (120 in-game day cycle)
- Debug mode with detailed logging
- Modular design for easy maintenance and extension

### Technical Details
- Written in Lua for RDR2 Script Hook compatibility
- Event-driven update system
- Efficient calculation algorithms
- Region-aware climate system
- Time-based progression system

## [Unreleased]

### Planned Features
- More granular weather sub-types
- Wind direction and speed systems
- Seasonal wildlife migration patterns
- UI overlay for season/weather information
- Custom regional definitions support
- Save/load functionality for season state
- Multiple language support
- Sound effect integration
- Particle effect enhancements
- Integration with other immersion mods

---

## Version History

- **1.0.0** - Initial release with core functionality

## Links

- [GitHub Repository](https://github.com/iboss21/tlw_season_manager)
- [Nexus Mods Page](https://www.nexusmods.com/reddeadredemption2/mods/7521)
- [Issue Tracker](https://github.com/iboss21/tlw_season_manager/issues)
