--[[
    DolyVpn - Système de protection contre les VPN/Proxy
    Développé par Doly
]]

DV = {}
DV.Cache = {}
DV.Config = Config

-- Vérifications des configurations critiques
if not DV.Config then
    print("^1[DolyVPN]^7 Erreur critique: La configuration n'a pas été chargée.")
    StopResource(GetCurrentResourceName())
    return
end

-- Vérification de l'email
if not DV.Config.OwnerEmail or DV.Config.OwnerEmail == "" then
    print("^1[" .. DV.Config.ProjectName .. "]^7 Erreur critique: L'email n'est pas configuré.")
    StopResource(GetCurrentResourceName())
    return
end

if string.find(string.lower(DV.Config.OwnerEmail), "example") then
    print("^1[" .. DV.Config.ProjectName .. "]^7 Erreur critique: L'email ne peut pas contenir 'example'. Veuillez configurer un email valide.")
    StopResource(GetCurrentResourceName())
    return
end

-- Vérification du webhook Discord
if DV.Config.EnableDiscordLogs then
    if not DV.Config.DiscordWebhook or DV.Config.DiscordWebhook == "" then
        print("^1[" .. DV.Config.ProjectName .. "]^7 Erreur critique: Les logs Discord sont activés mais aucun webhook n'est configuré.")
        StopResource(GetCurrentResourceName())
        return
    end
    
    if not string.match(DV.Config.DiscordWebhook, "^https://discord.com/api/webhooks/") then
        print("^1[" .. DV.Config.ProjectName .. "]^7 Erreur critique: Le webhook Discord n'est pas valide. Il doit commencer par 'https://discord.com/api/webhooks/'")
        StopResource(GetCurrentResourceName())
        return
    end
end

-- Vérification du seuil de détection
if not DV.Config.KickThreshold or DV.Config.KickThreshold < 0 then
    print("^1[" .. DV.Config.ProjectName .. "]^7 Erreur critique: Le seuil de détection n'est pas valide.")
    StopResource(GetCurrentResourceName())
    return
end

-- Vérification du temps de cache
if not DV.Config.CacheTime or DV.Config.CacheTime < 0 then
    print("^1[" .. DV.Config.ProjectName .. "]^7 Erreur critique: Le temps de cache n'est pas valide.")
    StopResource(GetCurrentResourceName())
    return
end

local classFiles = {
    'IPEntry',
    'VPNChecker'
}

for _, file in ipairs(classFiles) do
    local resourceName = GetCurrentResourceName()
    local classFile = LoadResourceFile(resourceName, 'classes/' .. file .. '.lua')
    if classFile then
        load(classFile)()
    else
        print("^1[" .. DV.Config.ProjectName .. "]^7 Erreur: Impossible de charger la classe " .. file)
    end
end

-- Charger les modules
local moduleFiles = {
    'utils',
    'logger',
    'discord',
    'cache',
    'checker',
    'commands'
}

for _, file in ipairs(moduleFiles) do
    local resourceName = GetCurrentResourceName()
    local moduleFile = LoadResourceFile(resourceName, 'modules/' .. file .. '.lua')
    if moduleFile then
        load(moduleFile)()
    else
        print("^1[" .. DV.Config.ProjectName .. "]^7 Erreur: Impossible de charger le module " .. file)
    end
end

DV.VPNChecker = VPNChecker:new()

AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
    DV.VPNChecker:checkPlayer(source, playerName, setKickReason, deferrals)
end)

Citizen.CreateThread(function()
    Citizen.Wait(3000)
    
    DV.Logger:printLogo()
    
    DV.Logger:printConfig()
    
    if DV.Config.EnableDiscordLogs and DV.Config.DiscordWebhook ~= "" then
        DV.Discord:sendLog(
            "🚀 Système démarré",
            "Le système de protection VPN/Proxy a été démarré avec succès.\n" ..
            "**État:** " .. (DV.Config.Enabled and "Activé" or "Désactivé") .. "\n" ..
            "**Seuil de détection:** " .. DV.Config.KickThreshold .. "\n" ..
            "**Durée du cache:** " .. DV.Utils:formatTime(DV.Config.CacheTime) .. "\n" ..
            "**Vérification ISP:** " .. (DV.Config.ISPVerificationEnabled and "Activée" or "Désactivée"),
            3447003 -- Bleu
        )
    end
end) 