-- TLW Season Manager
-- The Land of Wolves (www.wolves.land)
-- Developer: iBoss
-- Framework: LXRCore (with RSG-Core, VORP, QBCore adapters)

fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

name 'tlw_season_manager'
description 'Comprehensive 12-stage seasonal cycle manager with climate engine and pack automation'
author 'iBoss - The Land of Wolves'
version '1.0.0'
url 'https://wolves.land'

-- Shared files
shared_scripts {
    'config.lua',
    'shared/util.lua',
    'shared/framework.lua',
    'shared/regions.lua',
    'shared/climate.lua'
}

-- Server scripts
server_scripts {
    'server/main.lua',
    'server/scheduler.lua',
    'server/packs.lua'
}

-- Client scripts
client_scripts {
    'client/main.lua',
    'client/weather.lua',
    'client/nui.lua'
}

-- UI files
ui_page 'web/index.html'

files {
    'web/index.html',
    'web/app.js',
    'web/style.css',
    'web/assets/*.png',
    'web/assets/*.jpg'
}

-- Dependencies (optional, will work without these)
dependencies {
    -- Primary framework (one of these)
    -- 'lxr-core',
    -- 'rsg-core',
    -- 'vorp_core'
}

-- Exports for other resources
exports {
    'GetSeasonState',
    'GetCurrentStage',
    'GetCurrentTemperature',
    'GetRegionTemperature',
    'GetCurrentWeather',
    'GetStabilityFactor',
    'IsPackEnabled'
}

server_exports {
    'GetSeasonState',
    'SetStage',
    'FreezeStage',
    'RegisterSeasonPack',
    'GetAllRegionTemperatures'
}

lua54 'yes'
