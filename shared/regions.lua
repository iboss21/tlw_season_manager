-- TLW Season Manager - Regions Definition
-- Defines all regions with coordinates, climate zones, and adjacency

Regions = {}

-- ============================================================================
-- REGION DEFINITIONS (Up to 38 regions supported)
-- ============================================================================

Regions.List = {
    -- GRIZZLIES & AMBARINO (Northern Mountain Zone)
    {
        id = 1,
        name = "Grizzlies West",
        zone = "northern",
        center = vector3(-1324.0, 2400.0, 307.0),
        tempModifier = -8,
        neighbors = {2, 3, 7}
    },
    {
        id = 2,
        name = "Grizzlies East",
        zone = "northern",
        center = vector3(497.0, 1712.0, 195.0),
        tempModifier = -8,
        neighbors = {1, 3, 4, 8}
    },
    {
        id = 3,
        name = "Cumberland Forest",
        zone = "northern",
        center = vector3(296.0, 1099.0, 180.0),
        tempModifier = -5,
        neighbors = {1, 2, 4, 9}
    },
    
    -- ROANOKE RIDGE & NEW HANOVER (Central/Northern)
    {
        id = 4,
        name = "Roanoke Ridge",
        zone = "central",
        center = vector3(2142.0, 1219.0, 120.0),
        tempModifier = -2,
        neighbors = {2, 3, 5, 9, 10}
    },
    {
        id = 5,
        name = "Annesburg",
        zone = "central",
        center = vector3(2930.0, 1290.0, 48.0),
        tempModifier = 0,
        neighbors = {4, 10, 11}
    },
    
    -- HEARTLANDS & NEW HANOVER (Central Plains)
    {
        id = 6,
        name = "Heartlands - North",
        zone = "central",
        center = vector3(478.0, 469.0, 109.0),
        tempModifier = 1,
        neighbors = {7, 9, 10, 12}
    },
    {
        id = 7,
        name = "Heartlands - West",
        zone = "central",
        center = vector3(-526.0, 151.0, 55.0),
        tempModifier = 1,
        neighbors = {1, 6, 13, 14}
    },
    {
        id = 8,
        name = "Heartlands - Oil Fields",
        zone = "central",
        center = vector3(293.0, -123.0, 48.0),
        tempModifier = 2,
        neighbors = {2, 9, 12, 15}
    },
    {
        id = 9,
        name = "Heartlands - East",
        zone = "central",
        center = vector3(1056.0, 523.0, 95.0),
        tempModifier = 1,
        neighbors = {3, 4, 6, 8, 10}
    },
    {
        id = 10,
        name = "Emerald Ranch Area",
        zone = "central",
        center = vector3(1418.0, 295.0, 88.0),
        tempModifier = 0,
        neighbors = {4, 5, 6, 9, 11, 12}
    },
    
    -- LEMOYNE (Southern Humid)
    {
        id = 11,
        name = "Van Horn",
        zone = "coastal",
        center = vector3(2942.0, 521.0, 44.0),
        tempModifier = 2,
        neighbors = {5, 10, 16}
    },
    {
        id = 12,
        name = "Lemoyne - North",
        zone = "southern",
        center = vector3(1712.0, -385.0, 46.0),
        tempModifier = 3,
        neighbors = {6, 8, 10, 15, 16}
    },
    {
        id = 13,
        name = "Rhodes Area",
        zone = "southern",
        center = vector3(1370.0, -1315.0, 76.0),
        tempModifier = 4,
        neighbors = {7, 15, 17}
    },
    {
        id = 14,
        name = "Scarlett Meadows",
        zone = "southern",
        center = vector3(1561.0, -1859.0, 53.0),
        tempModifier = 4,
        neighbors = {15, 17, 18}
    },
    {
        id = 15,
        name = "Saint Denis",
        zone = "southern",
        center = vector3(2635.0, -1315.0, 46.0),
        tempModifier = 5,
        neighbors = {8, 12, 13, 14, 16}
    },
    {
        id = 16,
        name = "Bayou Nwa",
        zone = "southern",
        center = vector3(2210.0, -526.0, 42.0),
        tempModifier = 6,
        neighbors = {11, 12, 15, 19}
    },
    {
        id = 17,
        name = "Bluewater Marsh",
        zone = "southern",
        center = vector3(2014.0, -2074.0, 42.0),
        tempModifier = 5,
        neighbors = {13, 14, 18}
    },
    {
        id = 18,
        name = "Lagras",
        zone = "southern",
        center = vector3(2157.0, -2473.0, 41.0),
        tempModifier = 6,
        neighbors = {14, 17, 19}
    },
    {
        id = 19,
        name = "Kamassa River",
        zone = "southern",
        center = vector3(2676.0, -1824.0, 44.0),
        tempModifier = 5,
        neighbors = {16, 18}
    },
    
    -- WEST ELIZABETH (Central/Coastal)
    {
        id = 20,
        name = "Big Valley",
        zone = "central",
        center = vector3(-1779.0, 280.0, 153.0),
        tempModifier = 0,
        neighbors = {1, 21, 24}
    },
    {
        id = 21,
        name = "Strawberry",
        zone = "central",
        center = vector3(-1804.0, -386.0, 164.0),
        tempModifier = 1,
        neighbors = {20, 22, 24, 25}
    },
    {
        id = 22,
        name = "Tall Trees",
        zone = "central",
        center = vector3(-2245.0, -1614.0, 147.0),
        tempModifier = -1,
        neighbors = {21, 23, 26}
    },
    {
        id = 23,
        name = "Great Plains - North",
        zone = "central",
        center = vector3(-1416.0, -2166.0, 54.0),
        tempModifier = 2,
        neighbors = {22, 26, 27}
    },
    {
        id = 24,
        name = "Flat Iron Lake - North",
        zone = "coastal",
        center = vector3(-743.0, -199.0, 37.0),
        tempModifier = 2,
        neighbors = {7, 20, 21, 25}
    },
    {
        id = 25,
        name = "Blackwater",
        zone = "coastal",
        center = vector3(-815.0, -1324.0, 43.0),
        tempModifier = 3,
        neighbors = {21, 24, 27}
    },
    
    -- NEW AUSTIN (Desert Arid)
    {
        id = 26,
        name = "Great Plains - South",
        zone = "desert",
        center = vector3(-1807.0, -2645.0, 12.0),
        tempModifier = 5,
        neighbors = {22, 23, 28, 29}
    },
    {
        id = 27,
        name = "Hennigan's Stead",
        zone = "desert",
        center = vector3(-2640.0, -2933.0, 5.0),
        tempModifier = 7,
        neighbors = {23, 25, 26, 28}
    },
    {
        id = 28,
        name = "Cholla Springs",
        zone = "desert",
        center = vector3(-3732.0, -2601.0, -2.0),
        tempModifier = 8,
        neighbors = {26, 27, 29, 30}
    },
    {
        id = 29,
        name = "Armadillo",
        zone = "desert",
        center = vector3(-3732.0, -2603.0, -2.0),
        tempModifier = 9,
        neighbors = {26, 28, 31}
    },
    {
        id = 30,
        name = "Rio Bravo",
        zone = "desert",
        center = vector3(-4488.0, -2936.0, -10.0),
        tempModifier = 10,
        neighbors = {28, 32, 33}
    },
    {
        id = 31,
        name = "Gaptooth Ridge",
        zone = "desert",
        center = vector3(-5518.0, -2950.0, -2.0),
        tempModifier = 10,
        neighbors = {29, 32}
    },
    {
        id = 32,
        name = "Tumbleweed",
        zone = "desert",
        center = vector3(-5510.0, -2925.0, -2.0),
        tempModifier = 11,
        neighbors = {30, 31, 33}
    },
    {
        id = 33,
        name = "Perdido",
        zone = "desert",
        center = vector3(-4917.0, -3496.0, -11.0),
        tempModifier = 10,
        neighbors = {30, 32}
    },
    
    -- ADDITIONAL REGIONS
    {
        id = 34,
        name = "Manteca Falls",
        zone = "northern",
        center = vector3(-1552.0, 1657.0, 250.0),
        tempModifier = -6,
        neighbors = {1, 20}
    },
    {
        id = 35,
        name = "O'Creagh's Run",
        zone = "northern",
        center = vector3(1586.0, 1224.0, 154.0),
        tempModifier = -7,
        neighbors = {2, 4}
    },
    {
        id = 36,
        name = "Bacchus Station",
        zone = "central",
        center = vector3(541.0, -102.0, 49.0),
        tempModifier = 1,
        neighbors = {7, 8, 9}
    },
    {
        id = 37,
        name = "Heartland Overflow",
        zone = "coastal",
        center = vector3(436.0, -595.0, 42.0),
        tempModifier = 2,
        neighbors = {8, 12, 15}
    },
    {
        id = 38,
        name = "Lannahechee River",
        zone = "southern",
        center = vector3(2325.0, -1169.0, 42.0),
        tempModifier = 4,
        neighbors = {15, 16, 19}
    }
}

-- ============================================================================
-- CLIMATE ZONE DEFINITIONS
-- ============================================================================

Regions.Zones = {
    northern = {
        name = "Northern Mountain",
        baseTempModifier = -8,
        snowModifier = 0.3,
        windModifier = 0.2,
        description = "Cold mountainous region with increased snow"
    },
    central = {
        name = "Central Plains",
        baseTempModifier = 0,
        snowModifier = 0.0,
        windModifier = 0.1,
        description = "Temperate plains with moderate weather"
    },
    southern = {
        name = "Southern Humid",
        baseTempModifier = 5,
        snowModifier = -0.3,
        windModifier = -0.1,
        description = "Warm humid region, rarely snows"
    },
    desert = {
        name = "Desert Arid",
        baseTempModifier = 10,
        snowModifier = -0.5,
        windModifier = 0.15,
        description = "Hot arid desert with minimal precipitation"
    },
    coastal = {
        name = "Coastal Moderate",
        baseTempModifier = 2,
        snowModifier = -0.2,
        windModifier = 0.3,
        description = "Coastal areas with moderate temperatures"
    }
}

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

-- Get region by ID
function Regions.GetById(id)
    for _, region in ipairs(Regions.List) do
        if region.id == id then
            return region
        end
    end
    return nil
end

-- Get region by name
function Regions.GetByName(name)
    for _, region in ipairs(Regions.List) do
        if region.name == name then
            return region
        end
    end
    return nil
end

-- Get region by coordinates
function Regions.GetByCoords(coords)
    local closestRegion = nil
    local closestDistance = math.huge
    
    for _, region in ipairs(Regions.List) do
        local distance = Util.GetDistance(coords, region.center)
        if distance < closestDistance then
            closestDistance = distance
            closestRegion = region
        end
    end
    
    return closestRegion, closestDistance
end

-- Get zone definition
function Regions.GetZone(zoneName)
    return Regions.Zones[zoneName]
end

-- Get all neighbors of a region
function Regions.GetNeighbors(regionId)
    local region = Regions.GetById(regionId)
    if not region then return {} end
    
    local neighbors = {}
    for _, neighborId in ipairs(region.neighbors) do
        local neighbor = Regions.GetById(neighborId)
        if neighbor then
            table.insert(neighbors, neighbor)
        end
    end
    
    return neighbors
end

-- Get neighbor distances (for IDW)
function Regions.GetNeighborDistances(regionId)
    local region = Regions.GetById(regionId)
    if not region then return {} end
    
    local distances = {}
    for _, neighbor in ipairs(Regions.GetNeighbors(regionId)) do
        local distance = Util.GetDistance(region.center, neighbor.center)
        table.insert(distances, {
            region = neighbor,
            distance = distance
        })
    end
    
    return distances
end

-- Check if two regions are neighbors
function Regions.AreNeighbors(regionId1, regionId2)
    local region1 = Regions.GetById(regionId1)
    if not region1 then return false end
    
    return Util.TableContains(region1.neighbors, regionId2)
end

-- Get all regions in a zone
function Regions.GetByZone(zoneName)
    local regions = {}
    for _, region in ipairs(Regions.List) do
        if region.zone == zoneName then
            table.insert(regions, region)
        end
    end
    return regions
end

return Regions
