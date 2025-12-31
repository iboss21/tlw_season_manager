-- TLW Season Manager Configuration
-- The Land of Wolves (www.wolves.land)

Config = {}

-- ============================================================================
-- GENERAL SETTINGS
-- ============================================================================

Config.Debug = false -- Enable debug logging
Config.Brand = "The Land of Wolves" -- Branding
Config.Website = "www.wolves.land" -- Website

-- ============================================================================
-- FRAMEWORK SETTINGS
-- ============================================================================

Config.Framework = {
    Auto = true, -- Auto-detect framework
    Type = 'lxrcore', -- Options: 'lxrcore', 'rsg', 'vorp', 'qbcore', 'standalone'
    
    -- Core resource names for detection
    Cores = {
        lxrcore = 'lxr-core',
        rsg = 'rsg-core',
        vorp = 'vorp_core',
        qbcore = 'qb-core'
    }
}

-- ============================================================================
-- SEASONAL CYCLE SETTINGS
-- ============================================================================

Config.Seasons = {
    -- Progression mode: 'realtime' (minutes), 'gametime' (in-game days), 'manual' (admin only)
    ProgressionMode = 'realtime',
    
    -- For 'realtime' mode: minutes per stage (1440 = 24 hours)
    MinutesPerStage = 1440,
    
    -- For 'gametime' mode: in-game days per stage
    DaysPerStage = 10,
    
    -- Starting stage (1-12)
    StartingStage = 1,
    
    -- Auto-advance stages
    AutoAdvance = true,
    
    -- Allow manual override
    AllowManualOverride = true,
    
    -- Smooth transition duration (seconds)
    TransitionDuration = 300, -- 5 minutes
}

-- ============================================================================
-- DATE PROVIDER SETTINGS
-- ============================================================================

Config.DateProvider = {
    Type = 'internal', -- 'internal', 'export', 'txadmin'
    
    -- If 'export', specify the export to call
    ExportResource = 'some_calendar',
    ExportFunction = 'GetDate',
    
    -- Internal calendar settings
    Internal = {
        StartDate = {
            year = 2025,
            month = 1,
            day = 1
        },
        -- Real-time minutes per in-game day
        MinutesPerDay = 48
    }
}

-- ============================================================================
-- 12 SEASON STAGES DEFINITION
-- ============================================================================

Config.StageDefinitions = {
    -- SPRING STAGES
    {
        id = 1,
        name = "Early Spring",
        season = "spring",
        month = 3,
        description = "Warming temperatures, frequent rain",
        
        -- Base temperature (°C)
        baseTemp = 8,
        dailySwing = 8, -- Day/night variation
        
        -- Weather probabilities (must sum to ~1.0)
        weather = {
            clear = 0.25,
            overcast = 0.20,
            rain = 0.35,
            drizzle = 0.15,
            fog = 0.05,
            thunderstorm = 0.0,
            snow = 0.0
        },
        
        -- Thermodynamic factors
        solarGain = 1.2,
        evaporativeCooling = 1.3,
        insulation = 0.7,
        
        -- Packs to enable
        packs = {'tlw_spring_vegetation', 'tlw_blossoms'}
    },
    {
        id = 2,
        name = "Mid Spring",
        season = "spring",
        month = 4,
        description = "Pleasant temperatures, light showers",
        baseTemp = 15,
        dailySwing = 10,
        weather = {
            clear = 0.40,
            overcast = 0.15,
            rain = 0.25,
            drizzle = 0.15,
            fog = 0.05,
            thunderstorm = 0.0,
            snow = 0.0
        },
        solarGain = 1.4,
        evaporativeCooling = 1.2,
        insulation = 0.6,
        packs = {'tlw_spring_vegetation', 'tlw_blossoms', 'tlw_extreme_grass'}
    },
    {
        id = 3,
        name = "Late Spring",
        season = "spring",
        month = 5,
        description = "Warm days, occasional storms",
        baseTemp = 20,
        dailySwing = 12,
        weather = {
            clear = 0.45,
            overcast = 0.15,
            rain = 0.15,
            drizzle = 0.05,
            fog = 0.05,
            thunderstorm = 0.15,
            snow = 0.0
        },
        solarGain = 1.6,
        evaporativeCooling = 1.4,
        insulation = 0.5,
        packs = {'tlw_spring_vegetation', 'tlw_extreme_grass'}
    },
    
    -- SUMMER STAGES
    {
        id = 4,
        name = "Early Summer",
        season = "summer",
        month = 6,
        description = "Hot and humid with afternoon storms",
        baseTemp = 28,
        dailySwing = 14,
        weather = {
            clear = 0.50,
            overcast = 0.15,
            rain = 0.10,
            drizzle = 0.0,
            fog = 0.0,
            thunderstorm = 0.25,
            snow = 0.0
        },
        solarGain = 2.0,
        evaporativeCooling = 1.6,
        insulation = 0.4,
        packs = {'tlw_summer_vegetation', 'tlw_extreme_grass'}
    },
    {
        id = 5,
        name = "Mid Summer",
        season = "summer",
        month = 7,
        description = "Hottest period with heatwaves",
        baseTemp = 32,
        dailySwing = 16,
        weather = {
            clear = 0.60,
            overcast = 0.10,
            rain = 0.05,
            drizzle = 0.0,
            fog = 0.0,
            thunderstorm = 0.25,
            snow = 0.0
        },
        solarGain = 2.2,
        evaporativeCooling = 1.5,
        insulation = 0.3,
        packs = {'tlw_summer_vegetation', 'tlw_extreme_grass'}
    },
    {
        id = 6,
        name = "Late Summer",
        season = "summer",
        month = 8,
        description = "Still hot, gradual cooling begins",
        baseTemp = 28,
        dailySwing = 14,
        weather = {
            clear = 0.50,
            overcast = 0.15,
            rain = 0.10,
            drizzle = 0.05,
            fog = 0.05,
            thunderstorm = 0.15,
            snow = 0.0
        },
        solarGain = 1.8,
        evaporativeCooling = 1.5,
        insulation = 0.4,
        packs = {'tlw_summer_vegetation', 'tlw_extreme_grass'}
    },
    
    -- AUTUMN STAGES
    {
        id = 7,
        name = "Early Autumn",
        season = "autumn",
        month = 9,
        description = "Cooling temperatures, increased wind",
        baseTemp = 20,
        dailySwing = 12,
        weather = {
            clear = 0.35,
            overcast = 0.25,
            rain = 0.20,
            drizzle = 0.10,
            fog = 0.10,
            thunderstorm = 0.0,
            snow = 0.0
        },
        solarGain = 1.4,
        evaporativeCooling = 1.3,
        insulation = 0.6,
        packs = {'tlw_autumn_vegetation'}
    },
    {
        id = 8,
        name = "Mid Autumn",
        season = "autumn",
        month = 10,
        description = "Crisp air, frequent rain and fog",
        baseTemp = 12,
        dailySwing = 10,
        weather = {
            clear = 0.25,
            overcast = 0.30,
            rain = 0.25,
            drizzle = 0.10,
            fog = 0.10,
            thunderstorm = 0.0,
            snow = 0.0
        },
        solarGain = 1.0,
        evaporativeCooling = 1.2,
        insulation = 0.8,
        packs = {'tlw_autumn_vegetation'}
    },
    {
        id = 9,
        name = "Late Autumn",
        season = "autumn",
        month = 11,
        description = "First frost, winter approaching",
        baseTemp = 3,
        dailySwing = 8,
        weather = {
            clear = 0.20,
            overcast = 0.30,
            rain = 0.20,
            drizzle = 0.10,
            fog = 0.15,
            thunderstorm = 0.0,
            snow = 0.05
        },
        solarGain = 0.8,
        evaporativeCooling = 1.0,
        insulation = 1.0,
        packs = {'tlw_autumn_vegetation'}
    },
    
    -- WINTER STAGES
    {
        id = 10,
        name = "Early Winter",
        season = "winter",
        month = 12,
        description = "Cold with occasional snow",
        baseTemp = -5,
        dailySwing = 6,
        weather = {
            clear = 0.25,
            overcast = 0.30,
            rain = 0.05,
            drizzle = 0.0,
            fog = 0.15,
            thunderstorm = 0.0,
            snow = 0.25
        },
        solarGain = 0.6,
        evaporativeCooling = 0.8,
        insulation = 1.2,
        packs = {'tlw_snowpack', 'tlw_winter_wagons'}
    },
    {
        id = 11,
        name = "Mid Winter",
        season = "winter",
        month = 1,
        description = "Coldest period with heavy snow",
        baseTemp = -10,
        dailySwing = 5,
        weather = {
            clear = 0.20,
            overcast = 0.30,
            rain = 0.0,
            drizzle = 0.0,
            fog = 0.10,
            thunderstorm = 0.0,
            snow = 0.40
        },
        solarGain = 0.5,
        evaporativeCooling = 0.7,
        insulation = 1.4,
        packs = {'tlw_snowpack', 'tlw_winter_wagons', 'tlw_xmas_decorations'}
    },
    {
        id = 12,
        name = "Late Winter",
        season = "winter",
        month = 2,
        description = "Melting snow, transition to spring",
        baseTemp = 0,
        dailySwing = 7,
        weather = {
            clear = 0.25,
            overcast = 0.25,
            rain = 0.15,
            drizzle = 0.10,
            fog = 0.15,
            thunderstorm = 0.0,
            snow = 0.10
        },
        solarGain = 0.8,
        evaporativeCooling = 1.0,
        insulation = 1.1,
        packs = {'tlw_snowpack', 'tlw_winter_wagons'}
    }
}

-- ============================================================================
-- WEATHER SYSTEM SETTINGS
-- ============================================================================

Config.Weather = {
    -- Weather update interval (seconds)
    UpdateInterval = 300, -- 5 minutes
    
    -- Use persistent weather graph (prevents flicker)
    UsePersistentGraph = true,
    
    -- Weather transition costs (exit difficulty)
    TransitionCosts = {
        clear = {overcast = 1, fog = 2, drizzle = 3, rain = 4, thunderstorm = 6, snow = 8},
        overcast = {clear = 2, fog = 1, drizzle = 1, rain = 2, thunderstorm = 3, snow = 4},
        fog = {clear = 3, overcast = 1, drizzle = 2, rain = 3, thunderstorm = 5, snow = 3},
        drizzle = {clear = 3, overcast = 1, fog = 2, rain = 1, thunderstorm = 2, snow = 4},
        rain = {clear = 4, overcast = 2, fog = 2, drizzle = 1, thunderstorm = 1, snow = 3},
        thunderstorm = {clear = 6, overcast = 3, fog = 4, drizzle = 3, rain = 1, snow = 5},
        snow = {clear = 5, overcast = 3, fog = 3, drizzle = 4, rain = 4, thunderstorm = 6}
    },
    
    -- Minimum duration before allowing transition (seconds)
    MinimumDuration = {
        clear = 600, -- 10 minutes
        overcast = 300,
        fog = 420,
        drizzle = 300,
        rain = 480,
        thunderstorm = 360,
        snow = 600
    },
    
    -- Stability factor multiplier (higher = more stable weather)
    StabilityMultiplier = 1.0
}

-- ============================================================================
-- CLIMATE ENGINE SETTINGS
-- ============================================================================

Config.Climate = {
    -- Temperature update interval (seconds)
    UpdateInterval = 60, -- 1 minute
    
    -- Enable spatial adjacency (region bleed)
    EnableAdjacency = true,
    
    -- Adjacency weight factor (0.0-1.0)
    AdjacencyWeight = 0.3,
    
    -- Maximum adjacency distance (game units)
    MaxAdjacencyDistance = 5000,
    
    -- Active region distance (only compute for regions with nearby players)
    ActiveRegionDistance = 2000,
    
    -- Thermodynamic modifiers enabled
    EnableSolarGain = true,
    EnableEvaporativeCooling = true,
    EnableSnowCooling = true,
    EnableInsulation = true,
    
    -- Time of day curve (hourly temperature adjustment)
    HourlyModifiers = {
        [0] = -1.0, [1] = -1.2, [2] = -1.3, [3] = -1.4, 
        [4] = -1.3, [5] = -1.0, [6] = -0.5, [7] = 0.0,
        [8] = 0.5, [9] = 1.0, [10] = 1.5, [11] = 2.0,
        [12] = 2.5, [13] = 3.0, [14] = 3.2, [15] = 3.0,
        [16] = 2.5, [17] = 2.0, [18] = 1.5, [19] = 1.0,
        [20] = 0.5, [21] = 0.0, [22] = -0.5, [23] = -0.8
    }
}

-- ============================================================================
-- SEASONAL PACK MANAGER
-- ============================================================================

Config.Packs = {
    -- Auto-manage packs
    AutoManage = true,
    
    -- Pack management method: 'resource' (start/stop), 'export' (call toggle), 'event' (trigger event)
    ManagementMethod = 'resource',
    
    -- Registered packs (resource_name = {config})
    Registered = {
        ['tlw_spring_vegetation'] = {
            name = 'Spring Vegetation',
            method = 'resource',
            enableStages = {1, 2, 3},
            autoStart = true
        },
        ['tlw_blossoms'] = {
            name = 'Spring Blossoms',
            method = 'resource',
            enableStages = {1, 2},
            autoStart = true
        },
        ['tlw_extreme_grass'] = {
            name = 'Extreme Grass Density',
            method = 'resource',
            enableStages = {2, 3, 4, 5, 6},
            autoStart = true
        },
        ['tlw_summer_vegetation'] = {
            name = 'Summer Vegetation',
            method = 'resource',
            enableStages = {4, 5, 6},
            autoStart = true
        },
        ['tlw_autumn_vegetation'] = {
            name = 'Autumn Vegetation',
            method = 'resource',
            enableStages = {7, 8, 9},
            autoStart = true
        },
        ['tlw_snowpack'] = {
            name = 'Snow System',
            method = 'resource',
            enableStages = {10, 11, 12},
            autoStart = true
        },
        ['tlw_winter_wagons'] = {
            name = 'Abandoned Winter Wagons',
            method = 'resource',
            enableStages = {10, 11, 12},
            autoStart = true
        },
        ['tlw_xmas_decorations'] = {
            name = 'Christmas Decorations',
            method = 'resource',
            enableStages = {11}, -- Only Mid Winter
            autoStart = true
        }
    },
    
    -- Pack detection on startup
    DetectOnStartup = true,
    
    -- Log missing packs
    LogMissing = true,
    
    -- Grace period after stage change before toggling (seconds)
    ToggleDelay = 10
}

-- ============================================================================
-- NUI DASHBOARD SETTINGS
-- ============================================================================

Config.NUI = {
    -- Enable NUI
    Enabled = true,
    
    -- Keybind to open (admin only)
    Keybind = 'F10',
    
    -- Auto-refresh interval (milliseconds)
    RefreshInterval = 2000,
    
    -- Theme
    Theme = {
        primary = '#2c5f2d',
        secondary = '#97c2a6',
        background = '#1a1a1a',
        text = '#ffffff'
    }
}

-- ============================================================================
-- ADMIN COMMANDS
-- ============================================================================

Config.Commands = {
    -- Main season command
    BaseCommand = 'season',
    
    -- Subcommands
    Show = 'show',          -- /season show
    Set = 'set',            -- /season set <stage>
    Freeze = 'freeze',      -- /season freeze on|off
    Debug = 'debug',        -- /season debug on|off
    UI = 'ui',              -- /season ui
    Reload = 'reload',      -- /season reload
    
    -- Admin only
    AdminOnly = true
}
