// TLW Season Manager - NUI Application

let appVisible = false;
let currentData = null;

// ============================================================================
// MESSAGE HANDLING
// ============================================================================

window.addEventListener('message', (event) => {
    const data = event.data;
    
    switch (data.type) {
        case 'show':
            showUI();
            break;
        case 'hide':
            hideUI();
            break;
        case 'update':
            updateUI(data);
            break;
        case 'notification':
            showNotification(data);
            break;
    }
});

// ============================================================================
// UI CONTROL
// ============================================================================

function showUI() {
    document.getElementById('app').classList.remove('hidden');
    appVisible = true;
}

function hideUI() {
    document.getElementById('app').classList.add('hidden');
    appVisible = false;
}

function closeUI() {
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    });
}

// Close on ESC
document.addEventListener('keydown', (event) => {
    if (event.key === 'Escape' && appVisible) {
        closeUI();
    }
});

// ============================================================================
// UI UPDATE
// ============================================================================

function updateUI(data) {
    currentData = data;
    
    if (!data.state) return;
    
    const state = data.state;
    const region = data.region;
    
    // Update season info
    document.getElementById('stageNumber').textContent = state.stage;
    document.getElementById('stageName').textContent = state.stageName;
    document.getElementById('stageDescription').textContent = state.description;
    
    // Update progress
    const progressPercent = Math.floor(state.progress * 100);
    document.getElementById('progressPercent').textContent = progressPercent + '%';
    document.getElementById('progressFill').style.width = progressPercent + '%';
    
    // Update info grid
    document.getElementById('currentDay').textContent = state.day;
    document.getElementById('currentWeather').textContent = capitalizeFirst(state.weather);
    document.getElementById('stabilityFactor').textContent = state.stability.toFixed(2);
    
    if (state.timeUntilNext > 0) {
        document.getElementById('nextStage').textContent = formatDuration(state.timeUntilNext);
    } else {
        document.getElementById('nextStage').textContent = 'Manual';
    }
    
    // Update temperature
    if (region) {
        document.getElementById('currentTemp').textContent = region.temperature.toFixed(1) + '°C';
        document.getElementById('regionName').textContent = region.name;
        document.getElementById('regionZone').textContent = capitalizeFirst(region.zone.replace('_', ' '));
    }
    
    // Update thermodynamic factors
    updateThermodynamics(state);
    
    // Update season stages
    if (data.config && data.config.stages) {
        updateSeasonStages(data.config.stages, state.stage);
    }
    
    // Update region temperatures
    if (data.temperatures) {
        updateRegionTemperatures(data.temperatures);
    }
    
    // Update footer
    document.getElementById('lastUpdate').textContent = 'Last Update: ' + new Date().toLocaleTimeString();
}

function updateThermodynamics(state) {
    const factors = [
        { name: 'Weather', value: capitalizeFirst(state.weather) },
        { name: 'Stability', value: state.stability.toFixed(2) + 'x' },
        { name: 'Day Progress', value: Math.floor(state.progress * 100) + '%' },
        { name: 'Status', value: state.frozen ? 'Frozen' : 'Active' }
    ];
    
    const html = factors.map(factor => `
        <div class="factor-item">
            <span class="factor-name">${factor.name}</span>
            <span class="factor-value">${factor.value}</span>
        </div>
    `).join('');
    
    document.getElementById('factorList').innerHTML = html;
}

function updateSeasonStages(stages, currentStage) {
    const html = stages.map(stage => {
        const isActive = stage.id === currentStage;
        const seasonClass = stage.season || 'spring';
        
        return `
            <div class="stage-item ${seasonClass} ${isActive ? 'active' : ''}">
                <div class="stage-id">${stage.id}</div>
                <div class="stage-name">${stage.name}</div>
            </div>
        `;
    }).join('');
    
    document.getElementById('seasonStages').innerHTML = html;
}

function updateRegionTemperatures(temperatures) {
    // Limit to first 24 regions for display
    const displayCount = Math.min(Object.keys(temperatures).length, 24);
    
    const html = Object.entries(temperatures).slice(0, displayCount).map(([regionId, temp]) => {
        const region = getRegionName(parseInt(regionId));
        
        return `
            <div class="temp-item">
                <div class="region-name">${region}</div>
                <div class="region-temp">${temp.toFixed(1)}°C</div>
            </div>
        `;
    }).join('');
    
    document.getElementById('tempGrid').innerHTML = html;
}

// ============================================================================
// NOTIFICATIONS
// ============================================================================

function showNotification(data) {
    // Simple notification system (can be enhanced)
    console.log(`[${data.title}] ${data.message}`);
}

// ============================================================================
// UTILITIES
// ============================================================================

function capitalizeFirst(str) {
    if (!str) return '';
    return str.charAt(0).toUpperCase() + str.slice(1);
}

function formatDuration(seconds) {
    const days = Math.floor(seconds / 86400);
    const hours = Math.floor((seconds % 86400) / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    
    if (days > 0) {
        return `${days}d ${hours}h ${minutes}m`;
    } else if (hours > 0) {
        return `${hours}h ${minutes}m`;
    } else {
        return `${minutes}m`;
    }
}

function getRegionName(regionId) {
    const regionNames = {
        1: 'Grizzlies West', 2: 'Grizzlies East', 3: 'Cumberland Forest',
        4: 'Roanoke Ridge', 5: 'Annesburg', 6: 'Heartlands N',
        7: 'Heartlands W', 8: 'Oil Fields', 9: 'Heartlands E',
        10: 'Emerald Ranch', 11: 'Van Horn', 12: 'Lemoyne N',
        13: 'Rhodes', 14: 'Scarlett Meadows', 15: 'Saint Denis',
        16: 'Bayou Nwa', 17: 'Bluewater Marsh', 18: 'Lagras',
        19: 'Kamassa River', 20: 'Big Valley', 21: 'Strawberry',
        22: 'Tall Trees', 23: 'Great Plains N', 24: 'Flat Iron Lake N',
        25: 'Blackwater', 26: 'Great Plains S', 27: 'Hennigan\'s Stead',
        28: 'Cholla Springs', 29: 'Armadillo', 30: 'Rio Bravo',
        31: 'Gaptooth Ridge', 32: 'Tumbleweed', 33: 'Perdido',
        34: 'Manteca Falls', 35: 'O\'Creagh\'s Run', 36: 'Bacchus Station',
        37: 'Heartland Overflow', 38: 'Lannahechee River'
    };
    
    return regionNames[regionId] || `Region ${regionId}`;
}

function GetParentResourceName() {
    return window.location.hostname === '' ? 'tlw_season_manager' : window.location.hostname;
}

// ============================================================================
// INITIALIZATION
// ============================================================================

console.log('TLW Season Manager NUI initialized');
