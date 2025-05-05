--[[
    Module Checker
    Gère les vérifications des joueurs
]]

DV.Checker = {}

-- Vérifier si un joueur est whitelisté
function DV.Checker:isPlayerWhitelisted(source)
    if IsPlayerAceAllowed(source, "blockVPN.bypass") then
        return true
    end
    
    local identifiers = GetPlayerIdentifiers(source)
    for _, identifier in ipairs(identifiers) do
        if string.find(identifier, "discord:") then
            local discordID = string.gsub(identifier, "discord:", "")
            for _, whitelistedID in ipairs(DV.Config.WhitelistedDiscords) do
                if whitelistedID == discordID then
                    return true
                end
            end
        end
    end
    
    return false
end

-- Vérifier si une IP est blacklistée
function DV.Checker:isIPBlacklisted(ip)
    for _, blacklistedIP in ipairs(DV.Config.BlacklistedIPs) do
        if blacklistedIP == ip then
            return true
        end
    end
    return false
end

-- Vérifier si un ISP est légitime
function DV.Checker:isLegitimateISP(isp)
    if not isp then return false end
    
    for _, legitimateISP in ipairs(DV.Config.LegitimateISPs) do
        if string.find(string.lower(isp), string.lower(legitimateISP)) then
            return true
        end
    end
    
    return false
end

-- Vérifier si un ISP contient un mot-clé VPN
function DV.Checker:containsVPNKeyword(isp)
    if not isp then return false end
    
    for _, keyword in ipairs(DV.Config.VPNKeywords) do
        if string.find(string.lower(isp), string.lower(keyword)) then
            return keyword
        end
    end
    
    return false
end 