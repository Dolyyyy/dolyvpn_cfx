--[[
    Module Utils
    Fonctions utilitaires diverses
]]

DV.Utils = {}

-- Load la configuration
function DV.Utils:loadConfig()
    local resourceName = GetCurrentResourceName()
    local configFile = LoadResourceFile(resourceName, "config.lua")
    
    if not configFile then
        DV.Logger:print("ERROR", "Impossible de charger le fichier de configuration.", "error")
        return false
    end
    
    local oldConfig = DV.Config
    
    local success, err = pcall(function()
        load(configFile)()
    end)
    
    if not success then
        DV.Logger:print("ERROR", "Erreur lors du chargement de la configuration: " .. tostring(err), "error")
        DV.Config = oldConfig
        return false
    end
    
    if not Config then
        DV.Logger:print("ERROR", "Le fichier de configuration est invalide.", "error")
        DV.Config = oldConfig
        return false
    end
    
    DV.Config = Config
    
    DV.Logger:print("CONFIG", "Configuration chargée avec succès.", "success")
    return true
end

-- Diviser une chaîne
function DV.Utils:splitString(inputstr, sep)
    local t = {}
    local i = 1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end

-- Formater le temps
function DV.Utils:formatTime(seconds)
    local days = math.floor(seconds / 86400)
    seconds = seconds % 86400
    local hours = math.floor(seconds / 3600)
    seconds = seconds % 3600
    local minutes = math.floor(seconds / 60)
    seconds = seconds % 60
    
    if days > 0 then
        return string.format("%d jours, %d heures", days, hours)
    elseif hours > 0 then
        return string.format("%d heures, %d minutes", hours, minutes)
    elseif minutes > 0 then
        return string.format("%d minutes, %d secondes", minutes, seconds)
    else
        return string.format("%d secondes", seconds)
    end
end

-- Sauvegarder la configuration
function DV.Utils:saveConfig()
    local newConfig = "Config = {}\n\n"
    
    newConfig = newConfig .. "-- Configuration générale\n"
    newConfig = newConfig .. "Config.OwnerEmail = '" .. DV.Config.OwnerEmail .. "' -- Email de contact pour GetIPIntel (obligatoire)\n"
    newConfig = newConfig .. "Config.KickThreshold = " .. DV.Config.KickThreshold .. " -- Seuil de détection (0.99 recommandé)\n"
    newConfig = newConfig .. "Config.Flags = '" .. DV.Config.Flags .. "' -- Options de vérification (m = plus rapide et précis)\n"
    newConfig = newConfig .. "Config.KickReason = \"" .. DV.Config.KickReason .. "\" -- Message affiché lors du kick\n"
    newConfig = newConfig .. "Config.PrintFailed = " .. tostring(DV.Config.PrintFailed) .. " -- Afficher les connexions bloquées dans la console\n"
    newConfig = newConfig .. "Config.CacheTime = " .. DV.Config.CacheTime .. " -- Durée de mise en cache des IPs (en secondes)\n"
    newConfig = newConfig .. "Config.Enabled = " .. tostring(DV.Config.Enabled) .. " -- Activer/désactiver la protection\n"
    newConfig = newConfig .. "Config.WhitelistEnabled = " .. tostring(DV.Config.WhitelistEnabled) .. " -- Activer/désactiver la whitelist\n"
    newConfig = newConfig .. "Config.ISPVerificationEnabled = " .. tostring(DV.Config.ISPVerificationEnabled) .. " -- Activer/désactiver la vérification de l'ISP\n"
    newConfig = newConfig .. "Config.WhitelistMessage = \"" .. DV.Config.WhitelistMessage .. "\" -- Message affiché lors du refus d'accès par whitelist\n\n"
    
    newConfig = newConfig .. "-- Configuration Discord\n"
    newConfig = newConfig .. "Config.DiscordWebhook = '" .. DV.Config.DiscordWebhook .. "' -- URL du webhook Discord pour les logs\n"
    newConfig = newConfig .. "Config.AdminDiscordID = '" .. DV.Config.AdminDiscordID .. "' -- ID Discord de l'administrateur à mentionner en cas d'erreur critique\n"
    newConfig = newConfig .. "Config.EnableDiscordLogs = " .. tostring(DV.Config.EnableDiscordLogs) .. " -- Activer/désactiver les logs Discord\n\n"
    
    newConfig = newConfig .. "-- Liste des IDs Discord autorisés à bypasser la vérification\n"
    newConfig = newConfig .. "Config.WhitelistedDiscords = {\n"
    for _, id in ipairs(DV.Config.WhitelistedDiscords) do
        newConfig = newConfig .. "    \"" .. id .. "\",\n"
    end
    newConfig = newConfig .. "}\n\n"
    
    newConfig = newConfig .. "-- Liste des IPs blacklistées\n"
    newConfig = newConfig .. "Config.BlacklistedIPs = {\n"
    for _, ip in ipairs(DV.Config.BlacklistedIPs) do
        newConfig = newConfig .. "    \"" .. ip .. "\",\n"
    end
    newConfig = newConfig .. "}\n\n"
    
    newConfig = newConfig .. "-- Liste des opérateurs légitimes (ne seront pas considérés comme VPN)\n"
    newConfig = newConfig .. "Config.LegitimateISPs = {\n"
    for _, isp in ipairs(DV.Config.LegitimateISPs) do
        newConfig = newConfig .. "    \"" .. isp .. "\",\n"
    end
    newConfig = newConfig .. "}\n\n"
    
    newConfig = newConfig .. "-- Mots-clés typiques des fournisseurs de VPN/Proxy\n"
    newConfig = newConfig .. "Config.VPNKeywords = {\n"
    for _, keyword in ipairs(DV.Config.VPNKeywords) do
        newConfig = newConfig .. "    \"" .. keyword .. "\",\n"
    end
    newConfig = newConfig .. "}\n"
    
    SaveResourceFile(GetCurrentResourceName(), "config.lua", newConfig, -1)
    DV.Logger:print("CONFIG", "Configuration sauvegardée avec succès.", "success")
end

-- Vérifier le statut de l'API
function DV.Utils:checkAPIStatus()
    local success, response = pcall(function()
        local result = nil
        PerformHttpRequest("https://api.codoly.fr/vpn/status", function(errorCode, resultData, resultHeaders)
            result = { code = errorCode, data = resultData }
        end, 'GET')
        
        local timeoutCounter = 0
        while result == nil and timeoutCounter < 50 do
            Wait(100)
            timeoutCounter = timeoutCounter + 1
        end
        
        if result and result.code == 200 and result.data then
            local data = json.decode(result.data)
            return {
                ip_api = data.ip_api_status == "online",
                getipintel = data.getipintel_status == "online"
            }
        end
        return { ip_api = false, getipintel = false }
    end)
    
    if not success then
        return { ip_api = false, getipintel = false }
    end
    
    return response
end 