--[[
    Module Commands
    Gère les commandes administratives
]]

DV.Commands = {}

-- Fonction utilitaire pour générer le nom d'une commande
function DV.Commands:getCommandName(cmd)
    return DV.Config.CommandPrefix .. cmd
end

-- Enregistrer toutes les commandes
function DV.Commands:register()
    -- Commande d'aide
    RegisterCommand(self:getCommandName('help'), function(source, args, rawCommand)
        if source ~= 0 then
            return
        end
        
        DV.Logger:printLogo()
        DV.Logger:printConfig()
        
        print(" ")
        print("^5[" .. DV.Config.ProjectName .. "]^7 Liste des commandes disponibles :")
        print(" ")
        print("^6" .. self:getCommandName('protect') .. " [on|off]^7 - Activer ou désactiver la protection VPN")
        print("^6" .. self:getCommandName('wl') .. " [on|off]^7 - Activer ou désactiver la whitelist")
        print("^6" .. self:getCommandName('isp') .. " [on|off]^7 - Activer ou désactiver la vérification de l'ISP")
        print("^6" .. self:getCommandName('bypass') .. " [ID Discord]^7 - Ajouter un ID Discord à la liste blanche (VPN/Proxy/ConnexionWL)")
        print("^6" .. self:getCommandName('unbypass') .. " [ID Discord]^7 - Supprimer un ID Discord de la liste blanche (VPN/Proxy/ConnexionWL)")
        print("^6" .. self:getCommandName('listbypass') .. "^7 - Lister les IDs Discord dans la liste blanche")
        print("^6" .. self:getCommandName('block') .. " [IP]^7 - Ajouter une IP à la liste noire")
        print("^6" .. self:getCommandName('unblock') .. " [IP]^7 - Supprimer une IP de la liste noire")
        print("^6" .. self:getCommandName('listblock') .. "^7 - Lister les IPs blacklistées")
        print("^6" .. self:getCommandName('addisp') .. " [Nom de l'opérateur]^7 - Ajouter un opérateur légitime")
        print("^6" .. self:getCommandName('remisp') .. " [Nom de l'opérateur]^7 - Supprimer un opérateur légitime")
        print("^6" .. self:getCommandName('listisp') .. "^7 - Lister les opérateurs légitimes")
        print("^6" .. self:getCommandName('threshold') .. " [valeur]^7 - Définir le seuil de détection (entre 0 et 1)")
        print("^6" .. self:getCommandName('email') .. " [email]^7 - Définir l'email de contact pour GetIPIntel")
        print("^6" .. self:getCommandName('logs') .. " [on|off]^7 - Activer ou désactiver les logs Discord")
        print("^6" .. self:getCommandName('webhook') .. " [URL]^7 - Définir l'URL du webhook Discord")
        print("^6" .. self:getCommandName('admin') .. " [ID Discord]^7 - Définir l'ID Discord de l'administrateur")
        print("^6" .. self:getCommandName('cache') .. "^7 - Afficher les statistiques du cache")
        print("^6" .. self:getCommandName('clear') .. "^7 - Vider le cache")
        print("^6" .. self:getCommandName('reload') .. "^7 - Recharger la configuration")
        print("^6" .. self:getCommandName('help') .. "^7 - Afficher cette aide")
    end, false)
    
    -- Commande pour activer/désactiver la protection
    RegisterCommand(self:getCommandName('protect'), function(source, args, rawCommand)
        if source ~= 0 then
            return
        end
        
        if not args[1] then
            DV.Logger:print("INFO", "Utilisation: " .. self:getCommandName('protect') .. " [on|off]", "info")
            DV.Logger:print("INFO", "État actuel: " .. (DV.Config.Enabled and "Activé" or "Désactivé"), "info")
            return
        end
        
        local state = args[1]:lower()
        if state == "on" then
            DV.Config.Enabled = true
            DV.Utils:saveConfig()
            DV.Logger:print("CONFIG", "Protection VPN/Proxy activée.", "success")
            DV.Discord:sendLog(
                "🔧 Configuration modifiée",
                "**Action:** Protection VPN/Proxy activée",
                3447003 -- Bleu
            )
        elseif state == "off" then
            DV.Config.Enabled = false
            DV.Config.WhitelistEnabled = false
            DV.Config.ISPVerificationEnabled = false
            DV.Utils:saveConfig()
            DV.Logger:print("CONFIG", "Protection VPN/Proxy désactivée. Tous les checks sont désactivés.", "success")
            DV.Discord:sendLog(
                "🔧 Configuration modifiée",
                "**Action:** Protection VPN/Proxy désactivée\n" ..
                "**Note:** Tous les checks (Whitelist, ISP) ont été désactivés",
                3447003 -- Bleu
            )
        else
            DV.Logger:print("INFO", "Utilisation: " .. self:getCommandName('protect') .. " [on|off]", "info")
        end
    end, false)
    
    -- Commande pour activer/désactiver la whitelist
    RegisterCommand(self:getCommandName('wl'), function(source, args, rawCommand)
        if source ~= 0 then
            return
        end
        
        if not args[1] then
            DV.Logger:print("INFO", "Utilisation: " .. self:getCommandName('wl') .. " [on|off]", "info")
            DV.Logger:print("INFO", "État actuel: " .. (DV.Config.WhitelistEnabled and "Activé" or "Désactivé"), "info")
            return
        end
        
        local state = args[1]:lower()
        if state == "on" then
            DV.Config.WhitelistEnabled = true
            DV.Utils:saveConfig()
            DV.Logger:print("CONFIG", "Whitelist activée.", "success")
            DV.Discord:sendLog(
                "🔧 Configuration modifiée",
                "**Action:** Whitelist activée",
                3447003 -- Bleu
            )
        elseif state == "off" then
            DV.Config.WhitelistEnabled = false
            DV.Utils:saveConfig()
            DV.Logger:print("CONFIG", "Whitelist désactivée.", "success")
            DV.Discord:sendLog(
                "🔧 Configuration modifiée",
                "**Action:** Whitelist désactivée",
                3447003 -- Bleu
            )
        else
            DV.Logger:print("INFO", "Utilisation: " .. self:getCommandName('wl') .. " [on|off]", "info")
        end
    end, false)
    
    -- Alias pour la commande wl
    RegisterCommand(self:getCommandName('wl'), function(source, args, rawCommand)
        ExecuteCommand(self:getCommandName('wl') .. ' ' .. table.concat(args, ' '))
    end, false)
    
    -- Commande pour ajouter un ID Discord à la liste blanche
    RegisterCommand(self:getCommandName('bypass'), function(source, args, rawCommand)
        if source ~= 0 then
            return
        end
        
        if not args[1] then
            DV.Logger:print("INFO", "Utilisation: " .. self:getCommandName('bypass') .. " [ID Discord]", "info")
            return
        end
        
        local discordID = args[1]
        
        for _, whitelistedID in ipairs(DV.Config.WhitelistedDiscords) do
            if whitelistedID == discordID then
                DV.Logger:print("INFO", "L'ID Discord " .. discordID .. " est déjà dans la liste blanche.", "warning")
                return
            end
        end
        
        table.insert(DV.Config.WhitelistedDiscords, discordID)
        DV.Utils:saveConfig()
        
        DV.Logger:print("CONFIG", "L'ID Discord " .. discordID .. " a été ajouté à la liste blanche.", "success")
        DV.Discord:sendLog(
            "🔧 Liste blanche modifiée",
            "**Action:** Ajout d'un ID Discord à la liste blanche\n" ..
            "**ID Discord:** <@" .. discordID .. "> (" .. discordID .. ")",
            3447003 -- Bleu
        )
    end, false)
    
    -- Commande pour supprimer un ID Discord de la liste blanche
    RegisterCommand(self:getCommandName('unbypass'), function(source, args, rawCommand)
        if source ~= 0 then
            return
        end
        
        if not args[1] then
            DV.Logger:print("INFO", "Utilisation: " .. self:getCommandName('unbypass') .. " [ID Discord]", "info")
            return
        end
        
        local discordID = args[1]
        local found = false
        
        -- Supprimer l'ID Discord de la liste blanche
        for i, whitelistedID in ipairs(DV.Config.WhitelistedDiscords) do
            if whitelistedID == discordID then
                table.remove(DV.Config.WhitelistedDiscords, i)
                found = true
                break
            end
        end
        
        if found then
            DV.Utils:saveConfig()
            DV.Logger:print("CONFIG", "L'ID Discord " .. discordID .. " a été supprimé de la liste blanche.", "success")
            DV.Discord:sendLog(
                "🔧 Liste blanche modifiée",
                "**Action:** Suppression d'un ID Discord de la liste blanche\n" ..
                "**ID Discord:** <@" .. discordID .. "> (" .. discordID .. ")",
                3447003 -- Bleu
            )
        else
            DV.Logger:print("INFO", "L'ID Discord " .. discordID .. " n'est pas dans la liste blanche.", "warning")
        end
    end, false)
    
    -- Commande pour lister les IDs Discord dans la liste blanche
    RegisterCommand(self:getCommandName('listbypass'), function(source, args, rawCommand)
        if source ~= 0 then
            return
        end
        
        DV.Logger:print("INFO", "Liste des IDs Discord dans la liste blanche:", "info")
        if #DV.Config.WhitelistedDiscords == 0 then
            print("^5[" .. DV.Config.ProjectName .. "]^7 Aucun ID Discord dans la liste blanche.")
        else
            for i, discordID in ipairs(DV.Config.WhitelistedDiscords) do
                print("^5[" .. DV.Config.ProjectName .. "]^7 " .. i .. ". ^6" .. discordID .. "^7")
            end
        end
    end, false)
    
    -- Commande pour ajouter une IP à la liste noire
    RegisterCommand(self:getCommandName('block'), function(source, args, rawCommand)
        if source ~= 0 then
            return
        end
        
        if not args[1] then
            DV.Logger:print("INFO", "Utilisation: " .. self:getCommandName('block') .. " [IP]", "info")
            return
        end
        
        local ip = args[1]
        
        -- Vérifier si l'IP est déjà dans la liste noire
        for _, blacklistedIP in ipairs(DV.Config.BlacklistedIPs) do
            if blacklistedIP == ip then
                DV.Logger:print("INFO", "L'IP " .. ip .. " est déjà dans la liste noire.", "warning")
                return
            end
        end
        
        -- Ajouter l'IP à la liste noire
        table.insert(DV.Config.BlacklistedIPs, ip)
        DV.Utils:saveConfig()
        
        DV.Logger:print("CONFIG", "L'IP " .. ip .. " a été ajoutée à la liste noire.", "success")
        DV.Discord:sendLog(
            "🔧 Liste noire modifiée",
            "**Action:** Ajout d'une IP à la liste noire\n" ..
            "**IP:** " .. ip,
            3447003 -- Bleu
        )
    end, false)
    
    -- Commande pour supprimer une IP de la liste noire
    RegisterCommand(self:getCommandName('unblock'), function(source, args, rawCommand)
        if source ~= 0 then
            return
        end
        
        if not args[1] then
            DV.Logger:print("INFO", "Utilisation: " .. self:getCommandName('unblock') .. " [IP]", "info")
            return
        end
        
        local ip = args[1]
        local found = false
        
        -- Supprimer l'IP de la liste noire
        for i, blacklistedIP in ipairs(DV.Config.BlacklistedIPs) do
            if blacklistedIP == ip then
                table.remove(DV.Config.BlacklistedIPs, i)
                found = true
                break
            end
        end
        
        if found then
            DV.Utils:saveConfig()
            DV.Logger:print("CONFIG", "L'IP " .. ip .. " a été supprimée de la liste noire.", "success")
            DV.Discord:sendLog(
                "🔧 Liste noire modifiée",
                "**Action:** Suppression d'une IP de la liste noire\n" ..
                "**IP:** " .. ip,
                3447003 -- Bleu
            )
        else
            DV.Logger:print("INFO", "L'IP " .. ip .. " n'est pas dans la liste noire.", "warning")
        end
    end, false)
    
    -- Commande pour lister les IPs blacklistées
    RegisterCommand(self:getCommandName('listblock'), function(source, args, rawCommand)
        if source ~= 0 then
            return
        end
        
        DV.Logger:print("INFO", "Liste des IPs blacklistées:", "info")
        if #DV.Config.BlacklistedIPs == 0 then
            print("^5[" .. DV.Config.ProjectName .. "]^7 Aucune IP dans la liste noire.")
        else
            for i, ip in ipairs(DV.Config.BlacklistedIPs) do
                print("^5[" .. DV.Config.ProjectName .. "]^7 " .. i .. ". ^6" .. ip .. "^7")
            end
        end
    end, false)
    
    -- Commande pour ajouter un opérateur légitime
    RegisterCommand(self:getCommandName('addisp'), function(source, args, rawCommand)
        if source ~= 0 then
            return
        end
        
        if not args[1] then
            DV.Logger:print("INFO", "Utilisation: " .. self:getCommandName('addisp') .. " [Nom de l'opérateur]", "info")
            return
        end
        
        local isp = table.concat(args, " ")
        
        -- Vérifier si l'opérateur est déjà dans la liste
        for _, legitimateISP in ipairs(DV.Config.LegitimateISPs) do
            if legitimateISP:lower() == isp:lower() then
                DV.Logger:print("INFO", "L'opérateur " .. isp .. " est déjà dans la liste des opérateurs légitimes.", "warning")
                return
            end
        end
        
        -- Ajouter l'opérateur à la liste
        table.insert(DV.Config.LegitimateISPs, isp)
        DV.Utils:saveConfig()
        
        DV.Logger:print("CONFIG", "L'opérateur " .. isp .. " a été ajouté à la liste des opérateurs légitimes.", "success")
        DV.Discord:sendLog(
            "🔧 Liste des opérateurs légitimes modifiée",
            "**Action:** Ajout d'un opérateur légitime\n" ..
            "**Opérateur:** " .. isp,
            3447003 -- Bleu
        )
    end, false)
    
    -- Commande pour supprimer un opérateur légitime
    RegisterCommand(self:getCommandName('remisp'), function(source, args, rawCommand)
        if source ~= 0 then
            return
        end
        
        if not args[1] then
            DV.Logger:print("INFO", "Utilisation: " .. self:getCommandName('remisp') .. " [Nom de l'opérateur]", "info")
            return
        end
        
        local isp = table.concat(args, " ")
        local found = false
        
        -- Supprimer l'opérateur de la liste
        for i, legitimateISP in ipairs(DV.Config.LegitimateISPs) do
            if legitimateISP:lower() == isp:lower() then
                table.remove(DV.Config.LegitimateISPs, i)
                found = true
                break
            end
        end
        
        if found then
            DV.Utils:saveConfig()
            DV.Logger:print("CONFIG", "L'opérateur " .. isp .. " a été supprimé de la liste des opérateurs légitimes.", "success")
            DV.Discord:sendLog(
                "🔧 Liste des opérateurs légitimes modifiée",
                "**Action:** Suppression d'un opérateur légitime\n" ..
                "**Opérateur:** " .. isp,
                3447003 -- Bleu
            )
        else
            DV.Logger:print("INFO", "L'opérateur " .. isp .. " n'est pas dans la liste des opérateurs légitimes.", "warning")
        end
    end, false)
    
    -- Commande pour lister les opérateurs légitimes
    RegisterCommand(self:getCommandName('listisp'), function(source, args, rawCommand)
        if source ~= 0 then
            return
        end
        
        DV.Logger:print("INFO", "Liste des opérateurs légitimes:", "info")
        if #DV.Config.LegitimateISPs == 0 then
            print("^5[" .. DV.Config.ProjectName .. "]^7 Aucun opérateur légitime dans la liste.")
        else
            for i, isp in ipairs(DV.Config.LegitimateISPs) do
                print("^5[" .. DV.Config.ProjectName .. "]^7 " .. i .. ". ^6" .. isp .. "^7")
            end
        end
    end, false)
    
    -- Commande pour définir le seuil de détection
    RegisterCommand(self:getCommandName('threshold'), function(source, args, rawCommand)
        if source ~= 0 then
            return
        end
        
        if not args[1] then
            DV.Logger:print("INFO", "Utilisation: " .. self:getCommandName('threshold') .. " [valeur]", "info")
            DV.Logger:print("INFO", "Valeur actuelle: " .. DV.Config.KickThreshold, "info")
            return
        end
        
        local threshold = tonumber(args[1])
        if not threshold or threshold < 0 or threshold > 1 then
            DV.Logger:print("INFO", "La valeur doit être comprise entre 0 et 1.", "warning")
            return
        end
        
        DV.Config.KickThreshold = threshold
        DV.Utils:saveConfig()
        
        DV.Logger:print("CONFIG", "Le seuil de détection a été défini à " .. threshold, "success")
        DV.Discord:sendLog(
            "🔧 Configuration modifiée",
            "**Action:** Seuil de détection modifié\n" ..
            "**Nouvelle valeur:** " .. threshold,
            3447003 -- Bleu
        )
    end, false)
    
    -- Commande pour définir l'email de contact
    RegisterCommand(self:getCommandName('email'), function(source, args, rawCommand)
        if source ~= 0 then
            return
        end
        
        if not args[1] then
            DV.Logger:print("INFO", "Utilisation: " .. self:getCommandName('email') .. " [email]", "info")
            DV.Logger:print("INFO", "Email actuel: " .. DV.Config.OwnerEmail, "info")
            return
        end
        
        local email = args[1]
        DV.Config.OwnerEmail = email
        DV.Utils:saveConfig()
        
        DV.Logger:print("CONFIG", "L'email de contact a été défini à " .. email, "success")
        DV.Discord:sendLog(
            "🔧 Configuration modifiée",
            "**Action:** Email de contact modifié\n" ..
            "**Nouvel email:** " .. email,
            3447003 -- Bleu
        )
    end, false)
    
    -- Commande pour activer/désactiver les logs Discord
    RegisterCommand(self:getCommandName('logs'), function(source, args, rawCommand)
        if source ~= 0 then
            return
        end
        
        if not args[1] then
            DV.Logger:print("INFO", "Utilisation: " .. self:getCommandName('logs') .. " [on|off]", "info")
            DV.Logger:print("INFO", "État actuel: " .. (DV.Config.EnableDiscordLogs and "Activé" or "Désactivé"), "info")
            return
        end
        
        local state = args[1]:lower()
        if state == "on" then
            DV.Config.EnableDiscordLogs = true
            DV.Utils:saveConfig()
            DV.Logger:print("CONFIG", "Logs Discord activés.", "success")
            DV.Discord:sendLog(
                "🔧 Configuration modifiée",
                "**Action:** Logs Discord activés",
                3447003 -- Bleu
            )
        elseif state == "off" then
            DV.Config.EnableDiscordLogs = false
            DV.Utils:saveConfig()
            DV.Logger:print("CONFIG", "Logs Discord désactivés.", "success")
        else
            DV.Logger:print("INFO", "Utilisation: " .. self:getCommandName('logs') .. " [on|off]", "info")
        end
    end, false)
    
    -- Commande pour définir le webhook Discord
    RegisterCommand(self:getCommandName('webhook'), function(source, args, rawCommand)
        if source ~= 0 then
            return
        end
        
        if not args[1] then
            DV.Logger:print("INFO", "Utilisation: " .. self:getCommandName('webhook') .. " [URL]", "info")
            DV.Logger:print("INFO", "URL actuelle: " .. DV.Config.DiscordWebhook, "info")
            return
        end
        
        local webhook = args[1]
        DV.Config.DiscordWebhook = webhook
        DV.Utils:saveConfig()
        
        DV.Logger:print("CONFIG", "L'URL du webhook Discord a été définie.", "success")
        DV.Discord:sendLog(
            "🔧 Configuration modifiée",
            "**Action:** URL du webhook Discord modifiée",
            3447003 -- Bleu
        )
    end, false)
    
    -- Commande pour définir l'ID Discord de l'administrateur
    RegisterCommand(self:getCommandName('admin'), function(source, args, rawCommand)
        if source ~= 0 then
            return
        end
        
        if not args[1] then
            DV.Logger:print("INFO", "Utilisation: " .. self:getCommandName('admin') .. " [ID Discord]", "info")
            DV.Logger:print("INFO", "ID actuel: " .. DV.Config.AdminDiscordID, "info")
            return
        end
        
        local adminID = args[1]
        DV.Config.AdminDiscordID = adminID
        DV.Utils:saveConfig()
        
        DV.Logger:print("CONFIG", "L'ID Discord de l'administrateur a été défini à " .. adminID, "success")
        DV.Discord:sendLog(
            "🔧 Configuration modifiée",
            "**Action:** ID Discord de l'administrateur modifié\n" ..
            "**Nouvel ID:** <@" .. adminID .. "> (" .. adminID .. ")",
            3447003 -- Bleu
        )
    end, false)
    
    -- Commande pour afficher les statistiques du cache
    RegisterCommand(self:getCommandName('cache'), function(source, args, rawCommand)
        if source ~= 0 then
            return
        end
        
        local stats = DV.Cache:getStats()
        
        DV.Logger:print("CACHE", "Statistiques du cache:", "info")
        print("^5[" .. DV.Config.ProjectName .. "]^7 Nombre total d'entrées: ^6" .. stats.count .. "^7")
        print("^5[" .. DV.Config.ProjectName .. "]^7 Entrées VPN/Proxy: ^6" .. stats.vpnCount .. "^7")
        print("^5[" .. DV.Config.ProjectName .. "]^7 Entrées légitimes: ^6" .. stats.legitCount .. "^7")
        
        if stats.count > 0 then
            print("^5[" .. DV.Config.ProjectName .. "]^7 Liste des entrées:")
            for i, entry in ipairs(DV.Cache.entries) do
                entry:updateExpiresIn()
                local status = entry:getStatus()
                local statusColor = status == "VPN/Proxy" and "^1" or "^2"
                print("^5[" .. DV.Config.ProjectName .. "]^7 " .. i .. ". IP: ^6" .. entry.ip .. "^7, Probabilité: ^6" .. entry.probability .. "^7, ISP: ^6" .. entry.isp .. "^7, Status: " .. statusColor .. status .. "^7, Expire dans: ^6" .. DV.Utils:formatTime(entry.expiresIn) .. "^7")
            end
        end
    end, false)
    
    -- Commande pour vider le cache
    RegisterCommand(self:getCommandName('clear'), function(source, args, rawCommand)
        if source ~= 0 then
            return
        end
        
        local count = DV.Cache:clear()
        
        DV.Logger:print("CACHE", count .. " entrées ont été supprimées du cache.", "success")
        DV.Discord:sendLog(
            "🔧 Cache vidé",
            "**Action:** Cache vidé\n" ..
            "**Entrées supprimées:** " .. count,
            3447003 -- Bleu
        )
    end, false)
    
    -- Commande pour activer/désactiver la vérification de l'ISP
    RegisterCommand(self:getCommandName('isp'), function(source, args, rawCommand)
        if source ~= 0 then
            return
        end
        
        if not args[1] then
            DV.Logger:print("INFO", "Utilisation: " .. self:getCommandName('isp') .. " [on|off]", "info")
            DV.Logger:print("INFO", "État actuel: " .. (DV.Config.ISPVerificationEnabled and "Activé" or "Désactivé"), "info")
            return
        end
        
        local state = args[1]:lower()
        if state == "on" then
            DV.Config.ISPVerificationEnabled = true
            DV.Utils:saveConfig()
            DV.Logger:print("CONFIG", "Vérification de l'ISP activée.", "success")
            DV.Discord:sendLog(
                "🔧 Configuration modifiée",
                "**Action:** Vérification de l'ISP activée",
                3447003 -- Bleu
            )
        elseif state == "off" then
            DV.Config.ISPVerificationEnabled = false
            DV.Utils:saveConfig()
            DV.Logger:print("CONFIG", "Vérification de l'ISP désactivée.", "success")
            DV.Discord:sendLog(
                "🔧 Configuration modifiée",
                "**Action:** Vérification de l'ISP désactivée",
                3447003 -- Bleu
            )
        else
            DV.Logger:print("INFO", "Utilisation: " .. self:getCommandName('isp') .. " [on|off]", "info")
        end
    end, false)
    
    -- Commande pour recharger la configuration
    RegisterCommand(self:getCommandName('reload'), function(source, args, rawCommand)
        if source ~= 0 then
            return
        end
        
        DV.Utils:loadConfig()
        
        -- DV.Logger:print("CONFIG", "Configuration rechargée avec succès.", "success")
        DV.Discord:sendLog(
            "🔧 Configuration rechargée",
            "**Action:** Configuration rechargée\n" ..
            "**État:**\n" ..
            "- Protection VPN/Proxy: " .. (DV.Config.Enabled and "Activée" or "Désactivée") .. "\n" ..
            "- Whitelist: " .. (DV.Config.WhitelistEnabled and "Activée" or "Désactivée") .. "\n" ..
            "- Vérification ISP: " .. (DV.Config.ISPVerificationEnabled and "Activée" or "Désactivée") .. "\n" ..
            "- Logs Discord: " .. (DV.Config.EnableDiscordLogs and "Activés" or "Désactivés"),
            3447003 -- Bleu
        )
    end, false)
end

DV.Commands:register() 