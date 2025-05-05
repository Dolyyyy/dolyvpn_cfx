--[[
    Classe IPEntry
    Représente une entrée dans le cache des IPs
]]

IPEntry = {}
IPEntry.__index = IPEntry

function IPEntry:new(ip, probability, isp)
    local self = setmetatable({}, IPEntry)
    self.ip = ip
    self.probability = probability
    self.isp = isp or "Inconnu"
    self.cachedOn = os.time()
    self.expiresIn = 0
    return self
end

function IPEntry:isExpired()
    return (self.cachedOn + DV.Config.CacheTime) < os.time()
end

function IPEntry:updateExpiresIn()
    self.expiresIn = (self.cachedOn + DV.Config.CacheTime) - os.time()
    return self.expiresIn
end

function IPEntry:getStatus()
    return self.probability >= DV.Config.KickThreshold and "VPN/Proxy" or "Légitime"
end 