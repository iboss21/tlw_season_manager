# Installation Guide - Season Manager

## Prerequisites

Before installing Season Manager, ensure you have:

1. **Red Dead Redemption 2 (PC)** - Fully updated to the latest version
2. **Script Hook RDR2** - Download from [dev-c.com](http://dev-c.com/rdr2/scripthookrdr2/)
   - OR **RedM Framework** for multiplayer servers

## Installation Steps

### Method 1: Manual Installation

1. **Download the mod**
   - Get the latest release from [GitHub Releases](https://github.com/iboss21/tlw_season_manager/releases)
   - Or download from [Nexus Mods](https://www.nexusmods.com/reddeadredemption2/mods/7521)

2. **Locate your RDR2 directory**
   - Default location: `C:\Program Files\Rockstar Games\Red Dead Redemption 2\`
   - Steam: `C:\Program Files (x86)\Steam\steamapps\common\Red Dead Redemption 2\`
   - Epic Games: `C:\Program Files\Epic Games\RedDeadRedemption2\`

3. **Create scripts folder** (if it doesn't exist)
   ```
   Red Dead Redemption 2\scripts\
   ```

4. **Extract mod files**
   - Copy all files to: `Red Dead Redemption 2\scripts\season_manager\`
   - Your structure should look like:
     ```
     Red Dead Redemption 2\
     ├── scripts\
     │   └── season_manager\
     │       ├── main.lua
     │       ├── config.json
     │       ├── version.txt
     │       └── DOCUMENTATION.md
     ```

5. **Verify installation**
   - Launch the game
   - Check for the Season Manager initialization message
   - Weather should start following seasonal patterns

### Method 2: Mod Manager Installation

If using Vortex or another mod manager:

1. Download the mod archive
2. Add to Vortex as a new mod
3. Enable the mod
4. Deploy and launch the game

## Configuration

### First-Time Setup

1. Navigate to `scripts\season_manager\config.json`
2. Open with any text editor
3. Adjust settings to your preference:

```json
{
  "seasonManager": {
    "features": {
      "enableSeasonalCycle": true,
      "enableDynamicWeather": true,
      "enableTemperatureSystem": true
    },
    "seasonSettings": {
      "daysPerStage": 10,
      "startingStage": 1
    }
  }
}
```

### Common Configuration Changes

**Faster Season Progression**
```json
"daysPerStage": 5
```

**Start in Summer**
```json
"startingStage": 7
```

**Disable Temperature System**
```json
"enableTemperatureSystem": false
```

## Verification

After installation, verify the mod is working:

1. **Check for initialization**
   - Look for "[Season Manager] Initializing..." in logs
   
2. **Observe weather changes**
   - Weather should transition naturally
   - Should match the current season stage

3. **Enable debug mode** (if needed)
   ```json
   "debugSettings": {
     "enableLogging": true,
     "showStageInfo": true
   }
   ```

## Troubleshooting

### Mod not loading

**Check Script Hook**
- Ensure ScriptHook RDR2 is properly installed
- Download latest version from official site
- Files should be in the RDR2 root directory

**Check file paths**
- Verify all files are in `scripts\season_manager\`
- Ensure filenames are correct (case-sensitive on some systems)

**Check game version**
- Script Hook must match your game version
- Update Script Hook after game updates

### Weather not changing

**Disable conflicting mods**
- Other weather mods may interfere
- Disable temporarily to test

**Check configuration**
```json
"enableDynamicWeather": true
```

**Verify in-game time is advancing**
- Stand still and wait a few in-game hours
- Weather should transition

### Performance issues

**Reduce update frequency**
```json
"weatherSettings": {
  "transitionSpeed": 0.3
}
```

**Disable features you don't use**
```json
"features": {
  "enableTemperatureSystem": false
}
```

## Uninstallation

To remove Season Manager:

1. Navigate to `scripts\season_manager\`
2. Delete the entire folder
3. Restart the game

Weather will return to vanilla behavior.

## Updating

To update to a newer version:

1. **Backup your config.json**
   - Save your custom settings
   
2. **Delete old files**
   - Remove the old season_manager folder

3. **Install new version**
   - Follow installation steps above

4. **Restore config**
   - Copy your settings back to new config.json

## Additional Resources

- **Full Documentation**: See DOCUMENTATION.md
- **Support**: [GitHub Issues](https://github.com/iboss21/tlw_season_manager/issues)
- **Community**: [Nexus Mods Page](https://www.nexusmods.com/reddeadredemption2/mods/7521)

## Notes

- **Save compatibility**: This mod does not affect save files
- **Multiplayer**: Use RedM version for multiplayer servers
- **Performance**: Minimal impact on most systems
- **Conflicts**: May conflict with other weather/season mods

---

**Need help? Open an issue on GitHub or ask in the Nexus Mods comments!**
