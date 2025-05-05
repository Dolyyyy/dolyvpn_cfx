--[[
    Classe VPNChecker
    Gère la vérification des VPN/Proxy
]]

VPNChecker = {}
VPNChecker.__index = VPNChecker

function VPNChecker:new()
    local self = setmetatable({}, VPNChecker)
    return self
end

function VPNChecker:checkPlayer(source, playerName, setKickReason, deferrals)
    -- Vérifier si la protection est activée
    if not DV.Config.Enabled then
        deferrals.done()
        DV.Logger:print("INFO", "Protection désactivée - " .. playerName .. " a été autorisé à se connecter", "info")
        return
    end
    
    if GetNumPlayerIndices() < GetConvarInt('sv_maxclients', 32) then
        deferrals.defer()
        deferrals.update("Vérification des informations du joueur. Veuillez patienter.")
        
        local playerIP = GetPlayerEP(source)
        if string.match(playerIP, ":") then
            playerIP = DV.Utils:splitString(playerIP, ":")[1]
        end
        
        -- Récupérer l'ID Discord du joueur
        local discordID = "Non disponible"
        local identifiers = GetPlayerIdentifiers(source)
        for _, identifier in ipairs(identifiers) do
            if string.find(identifier, "discord:") then
                discordID = string.gsub(identifier, "discord:", "")
                break
            end
        end
        
        -- Vérifier si la whitelist est activée et si le joueur est autorisé
        if DV.Config.WhitelistEnabled and not self:isPlayerWhitelisted(source) then
            deferrals.done(DV.Config.WhitelistMessage)
            DV.Discord:sendLog(
                "❌ Connexion bloquée (Whitelist)",
                "**Joueur:** " .. playerName .. "\n" ..
                "**IP:** " .. playerIP .. "\n" ..
                "**Discord:** <@" .. discordID .. "> (" .. discordID .. ")\n" ..
                "**Raison:** Joueur non whitelisté",
                15158332 -- Rouge
            )
            return
        end
        
        -- Vérifier si le joueur est autorisé à bypasser la vérification
        if self:isPlayerWhitelisted(source) then
            deferrals.done()
            DV.Discord:sendLog(
                "✅ Connexion autorisée (Whitelist)",
                "**Joueur:** " .. playerName .. "\n" ..
                "**IP:** " .. playerIP .. "\n" ..
                "**Discord:** <@" .. discordID .. "> (" .. discordID .. ")\n" ..
                "**Raison:** Joueur dans la liste blanche",
                5763719 -- Vert
            )
            return
        end
        
        -- Vérifier si l'IP est blacklistée
        if self:isIPBlacklisted(playerIP) then
            deferrals.done("Votre IP a été blacklistée sur ce serveur.")
            if DV.Config.PrintFailed then
                DV.Logger:print("BLACKLIST", playerName .. ' a été bloqué car son IP est blacklistée: ' .. playerIP, "error")
            end
            DV.Discord:sendLog(
                "❌ Connexion bloquée (IP Blacklistée)",
                "**Joueur:** " .. playerName .. "\n" ..
                "**IP:** " .. playerIP .. "\n" ..
                "**Discord:** <@" .. discordID .. "> (" .. discordID .. ")\n" ..
                "**Raison:** IP dans la liste noire",
                15158332 -- Rouge
            )
            return
        end
        
        -- Vérifier si l'IP est en cache
        local cachedEntry = DV.Cache:getEntry(playerIP)
        if cachedEntry then
            if cachedEntry.probability >= DV.Config.KickThreshold then
                deferrals.done(DV.Config.KickReason)
                if DV.Config.PrintFailed then
                    DV.Logger:print("BLOQUÉ", playerName .. ' a été bloqué car il utilise un VPN/Proxy (IP: ' .. playerIP .. ', Probabilité: ' .. cachedEntry.probability .. ', ISP: ' .. (cachedEntry.isp or "Inconnu") .. ')', "error")
                end
                DV.Logger:print("CACHE", playerName .. " a été vérifié (Source: Cache) - Connexion refusée", "error")
                DV.Discord:sendLog(
                    "❌ Connexion bloquée (VPN/Proxy - Cache)",
                    "**Joueur:** " .. playerName .. "\n" ..
                    "**IP:** " .. playerIP .. "\n" ..
                    "**Discord:** <@" .. discordID .. "> (" .. discordID .. ")\n" ..
                    "**Probabilité:** " .. cachedEntry.probability .. "\n" ..
                    "**ISP:** " .. (cachedEntry.isp or "Inconnu") .. "\n" ..
                    "**Source:** Cache (expire dans " .. DV.Utils:formatTime(cachedEntry.expiresIn) .. ")",
                    15158332 -- Rouge
                )
                return
            else 
                deferrals.done()
                -- DV.Logger:print("CACHE", playerName .. " a été vérifié (Source: Cache) - Connexion autorisée", "success")
                DV.Discord:sendLog(
                    "✅ Connexion autorisée (Cache)",
                    "**Joueur:** " .. playerName .. "\n" ..
                    "**IP:** " .. playerIP .. "\n" ..
                    "**Discord:** <@" .. discordID .. "> (" .. discordID .. ")\n" ..
                    "**Probabilité:** " .. cachedEntry.probability .. "\n" ..
                    "**ISP:** " .. (cachedEntry.isp or "Inconnu") .. "\n" ..
                    "**Source:** Cache (expire dans " .. DV.Utils:formatTime(cachedEntry.expiresIn) .. ")",
                    5763719 -- Vert
                )
                return
            end
        end
        
        -- Vérifier l'ISP de l'IP
        self:checkIPInfo(playerIP, function(isp)
            if not DV.Config.ISPVerificationEnabled then
                deferrals.done()
                DV.Discord:sendLog(
                    "✅ Connexion autorisée (ISP désactivé)",
                    "**Joueur:** " .. playerName .. "\n" ..
                    "**IP:** " .. playerIP .. "\n" ..
                    "**Discord:** <@" .. discordID .. "> (" .. discordID .. ")\n" ..
                    "**Raison:** Vérification ISP désactivée",
                    5763719 -- Vert
                )
                return
            end
            
            -- Vérifier si l'ISP est légitime
            if self:isLegitimateISP(isp) then
                DV.Cache:addEntry(playerIP, 0, isp)
                deferrals.done()
                DV.Discord:sendLog(
                    "✅ Connexion autorisée (ISP Légitime)",
                    "**Joueur:** " .. playerName .. "\n" ..
                    "**IP:** " .. playerIP .. "\n" ..
                    "**Discord:** <@" .. discordID .. "> (" .. discordID .. ")\n" ..
                    "**ISP:** " .. isp .. "\n" ..
                    "**Raison:** ISP dans la liste des opérateurs légitimes",
                    5763719 -- Vert
                )
                return
            end
            
            -- Vérifier si l'ISP contient des mots-clés de VPN
            local vpnKeyword = self:containsVPNKeyword(isp)
            if vpnKeyword then
                DV.Cache:addEntry(playerIP, 1, isp)
                deferrals.done(DV.Config.KickReason)
                if DV.Config.PrintFailed then
                    DV.Logger:print("BLOQUÉ", playerName .. ' a été bloqué car son ISP contient un mot-clé VPN (IP: ' .. playerIP .. ', ISP: ' .. isp .. ', Mot-clé: ' .. vpnKeyword .. ')', "error")
                end
                DV.Logger:print("VERIF", playerName .. " a été vérifié (Source: Nouvelle vérification) - Connexion refusée", "error")
                DV.Discord:sendLog(
                    "❌ Connexion bloquée (VPN détecté)",
                    "**Joueur:** " .. playerName .. "\n" ..
                    "**IP:** " .. playerIP .. "\n" ..
                    "**Discord:** <@" .. discordID .. "> (" .. discordID .. ")\n" ..
                    "**ISP:** " .. isp .. "\n" ..
                    "**Mot-clé détecté:** " .. vpnKeyword,
                    15158332 -- Rouge
                )
                return
            end
            
            -- Vérifier avec GetIPIntel
            self:checkWithGetIPIntel(playerIP, isp, function(probability)
                DV.Cache:addEntry(playerIP, probability, isp)
                
                if probability >= DV.Config.KickThreshold then
                    deferrals.done(DV.Config.KickReason)
                    if DV.Config.PrintFailed then
                        DV.Logger:print("BLOQUÉ", playerName .. ' a été bloqué avec une probabilité de ' .. probability .. '/1 (IP: ' .. playerIP .. ', ISP: ' .. isp .. ')', "error")
                    end
                    DV.Logger:print("VERIF", playerName .. " a été vérifié (Source: Nouvelle vérification) - Connexion refusée", "error")
                    DV.Discord:sendLog(
                        "❌ Connexion bloquée (VPN/Proxy - GetIPIntel)",
                        "**Joueur:** " .. playerName .. "\n" ..
                        "**IP:** " .. playerIP .. "\n" ..
                        "**Discord:** <@" .. discordID .. "> (" .. discordID .. ")\n" ..
                        "**Probabilité:** " .. probability .. "\n" ..
                        "**ISP:** " .. isp .. "\n" ..
                        "**Source:** GetIPIntel",
                        15158332 -- Rouge
                    )
                else 
                    deferrals.done()
                    DV.Discord:sendLog(
                        "✅ Connexion autorisée (GetIPIntel)",
                        "**Joueur:** " .. playerName .. "\n" ..
                        "**IP:** " .. playerIP .. "\n" ..
                        "**Discord:** <@" .. discordID .. "> (" .. discordID .. ")\n" ..
                        "**Probabilité:** " .. probability .. "\n" ..
                        "**ISP:** " .. isp .. "\n" ..
                        "**Source:** GetIPIntel",
                        5763719 -- Vert
                    )
                end
            end)
        end)
    else
        deferrals.done("Le serveur est plein.")
    end
end

function VPNChecker:isIPBlacklisted(ip)
    for _, blacklistedIP in ipairs(DV.Config.BlacklistedIPs) do
        if blacklistedIP == ip then
            return true
        end
    end
    return false
end

function VPNChecker:isPlayerWhitelisted(source)
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

function VPNChecker:isLegitimateISP(isp)
    if not isp then return false end
    
    for _, legitimateISP in ipairs(DV.Config.LegitimateISPs) do
        if string.find(string.lower(isp), string.lower(legitimateISP)) then
            return true
        end
    end
    
    return false
end

function VPNChecker:containsVPNKeyword(isp)
    if not isp then return false end
    
    for _, keyword in ipairs(DV.Config.VPNKeywords) do
        if string.find(string.lower(isp), string.lower(keyword)) then
            return keyword
        end
    end
    
    return false
end

function VPNChecker:checkIPInfo(ip, callback)
    PerformHttpRequest('https://api.codoly.fr/vpn/check?action=getISP&ip=' .. ip, function(statusCode, response, headers)
        local isp = "Inconnu"
        if response then
            local data = json.decode(response)
            if data and data.isp then
                isp = data.isp
            end
        end
        callback(isp)
    end)
end

function VPNChecker:checkWithGetIPIntel(ip, isp, callback)
    local ownerEmail = DV.Config.OwnerEmail
    local flags = DV.Config.Flags
    
    if string.find(ownerEmail, "example") or ownerEmail == "" or ownerEmail == nil then
        DV.Logger:print("ERREUR", "Email de contact invalide", "error")
        callback(-1)
        return
    end

    PerformHttpRequest('https://api.codoly.fr/vpn/check?action=checkVPN&ip=' .. ip .. '&email=' .. ownerEmail .. '&flags=' .. flags, function(statusCode, response, headers)
        local probability = 0
        
        if response then
            if tonumber(response) == -5 then
                DV.Logger:print("ERREUR", "GetIPIntel semble avoir bloqué la connexion avec le code d'erreur 5 (Email incorrect, email bloqué ou IP bloquée. Essayez de changer l'email de contact)", "error")
                probability = -5
                DV.Discord:sendLog(
                    "⚠️ Email invalide",
                    "**Action:** Tentative de connexion\n" ..
                    "**Joueur:** " .. playerName .. "\n" ..
                    "**IP:** " .. playerIP .. "\n" ..
                    "**Discord:** <@" .. discordID .. "> (" .. discordID .. ")\n" ..
                    "**Erreur:** Email de contact invalide\n" ..
                    "Utilisez la commande '" .. DV.Config.CommandPrefix .. "email' pour définir un email valide.",
                    15158332, -- Rouge
                    true -- Ping l'administrateur
                )
            elseif tonumber(response) == -6 then
                DV.Logger:print("ERREUR", "Un email de contact valide est requis!", "error")
                probability = -6
                DV.Discord:sendLog(
                    "⚠️ Erreur critique GetIPIntel",
                    "GetIPIntel a retourné une erreur code -6\n" ..
                    "Un email de contact valide est requis!\n" ..
                    "Utilisez la commande 'lcemail' pour définir un email valide.",
                    16776960, -- Jaune
                    true -- Ping l'admin
                )
            elseif tonumber(response) == -4 then
                DV.Logger:print("ERREUR", "Impossible d'atteindre la base de données. Probablement en cours de mise à jour.", "error")
                probability = -4
                DV.Discord:sendLog(
                    "⚠️ Erreur GetIPIntel",
                    "GetIPIntel a retourné une erreur code -4\n" ..
                    "Impossible d'atteindre la base de données. Probablement en cours de mise à jour.",
                    16776960 -- Jaune
                )
            elseif tonumber(response) == -2 then
                DV.Logger:print("ERREUR", "IP invalide ou privée.", "error")
                probability = -2
                DV.Discord:sendLog(
                    "⚠️ Erreur GetIPIntel",
                    "GetIPIntel a retourné une erreur code -2\n" ..
                    "IP invalide ou privée: " .. ip,
                    16776960 -- Jaune
                )
            elseif tonumber(response) == -1 then
                DV.Logger:print("ERREUR", "Aucun paramètre d'IP fourni.", "error")
                probability = -1
                DV.Discord:sendLog(
                    "⚠️ Erreur GetIPIntel",
                    "GetIPIntel a retourné une erreur code -1\n" ..
                    "Aucun paramètre d'IP fourni.",
                    16776960 -- Jaune
                )
            elseif tonumber(response) == -3 then
                DV.Logger:print("ERREUR", "Vous avez dépassé la limite de requêtes par jour.", "error")
                probability = -3
                DV.Discord:sendLog(
                    "⚠️ Erreur critique GetIPIntel",
                    "GetIPIntel a retourné une erreur code -3\n" ..
                    "Vous avez dépassé la limite de requêtes par jour.",
                    16776960, -- Jaune
                    true -- Ping l'admin
                )
            else
                probability = tonumber(response)
            end
        end
        
        callback(probability)
    end)
end 