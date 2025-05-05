--[[
    Module Cache
    Gère le cache des IPs vérifiées
]]

DV.Cache = {}
DV.Cache.entries = {}

-- Ajouter une entrée au cache
function DV.Cache:addEntry(ip, probability, isp)
    local entry = IPEntry:new(ip, probability, isp)
    table.insert(self.entries, entry)
end

-- Récupérer une entrée du cache
function DV.Cache:getEntry(ip)
    for i = #self.entries, 1, -1 do
        local entry = self.entries[i]
        if entry:isExpired() then
            table.remove(self.entries, i)
        end
    end
    
    for _, entry in ipairs(self.entries) do
        if entry.ip == ip then
                entry:updateExpiresIn()
                return entry
        end
    end
    
    return nil
end

-- Vider le cache
function DV.Cache:clear()
    local count = #self.entries
    self.entries = {}
    return count
end

-- Obtenir les statistiques du cache
function DV.Cache:getStats()
    local stats = {
        count = #self.entries,
        vpnCount = 0,
        legitCount = 0
    }
    
    for _, entry in ipairs(self.entries) do
        if entry.probability >= DV.Config.KickThreshold then
            stats.vpnCount = stats.vpnCount + 1
        else
            stats.legitCount = stats.legitCount + 1
        end
    end
    
    return stats
end 