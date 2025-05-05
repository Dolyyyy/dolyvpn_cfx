--[[
    Module Logger
    Gère l'affichage des messages dans la console
]]

DV.Logger = {}

DV.Logger.types = {
    info = "^5",
    success = "^2",
    warning = "^3",
    error = "^1"
}

function DV.Logger:print(prefix, message, type)
    local typeColor = self.types[type] or self.types.info
    print(typeColor .. "[" .. DV.Config.ProjectName .. "][" .. prefix .. "]^7 " .. message)
end

function DV.Logger:printLogo()
    print([[ 
^4    ____  ____  ____  ___    ______  _   __
^4   / __ \/ __ \/ /\ \/ / |  / / __ \/ | / /
^4  / / / / / / / /  \  /| | / / /_/ /  |/ / 
^4 / /_/ / /_/ / /___/ / | |/ / ____/ /|  /  
^4/_____/\____/_____/_/  |___/_/   /_/ |_/                                   
^7]])
end

function DV.Logger:printConfig()
    local apiStatus = DV.Utils:checkAPIStatus()
    
    print("^5[" .. DV.Config.ProjectName .. "]^7 ======== Configuration actuelle ========")
    print("^5[" .. DV.Config.ProjectName .. "]^7 Projet: ^8" .. DV.Config.ProjectName)
    print("^5[" .. DV.Config.ProjectName .. "]^7 Protection VPN/Proxy: " .. (DV.Config.Enabled and "^2Activée^7" or "^1Désactivée^7"))
    print("^5[" .. DV.Config.ProjectName .. "]^7 Logs Discord: " .. (DV.Config.EnableDiscordLogs and "^2Activés^7" or "^1Désactivés^7"))
    print("^5[" .. DV.Config.ProjectName .. "]^7 Whitelist: " .. (DV.Config.WhitelistEnabled and "^2Activée^7" or "^1Désactivée^7"))
    print("^5[" .. DV.Config.ProjectName .. "]^7 Vérification de l'ISP (FAI): " .. (DV.Config.ISPVerificationEnabled and "^2Activée^7" or "^1Désactivée^7"))
    print("^5[" .. DV.Config.ProjectName .. "]^7 -------------------------------------")
    print("^5[" .. DV.Config.ProjectName .. "]^7 Préfixe de commande: ^6" .. DV.Config.CommandPrefix)
    print("^5[" .. DV.Config.ProjectName .. "]^7 Email de contact: ^6" .. (DV.Config.OwnerEmail ~= "" and DV.Config.OwnerEmail or "^1Non défini^7"))
    print("^5[" .. DV.Config.ProjectName .. "]^7 Seuil de détection: ^6" .. DV.Config.KickThreshold .. "^7")
    print("^5[" .. DV.Config.ProjectName .. "]^7 Durée du cache: ^6" .. DV.Utils:formatTime(DV.Config.CacheTime) .. "^7")
    print("^5[" .. DV.Config.ProjectName .. "]^7 Opérateurs légitimes: ^6" .. #DV.Config.LegitimateISPs .. "^7")
    print("^5[" .. DV.Config.ProjectName .. "]^7 IDs Discord whitelistés: ^6" .. #DV.Config.WhitelistedDiscords .. "^7")
    print("^5[" .. DV.Config.ProjectName .. "]^7 IPs blacklistées: ^6" .. #DV.Config.BlacklistedIPs .. "^7")
    print("^5[" .. DV.Config.ProjectName .. "]^7 -------------------------------------")
    print("^5[" .. DV.Config.ProjectName .. "]^7 Statut API GetISP: " .. (apiStatus.ip_api and "^2En ligne^7" or "^1Hors ligne^7"))
    print("^5[" .. DV.Config.ProjectName .. "]^7 Statut API CheckVPN: " .. (apiStatus.getipintel and "^2En ligne^7" or "^1Hors ligne^7"))
    print("^5[" .. DV.Config.ProjectName .. "]^7 ======================================")
    print("^5[" .. DV.Config.ProjectName .. "]^7 Utilisez la commande ^6'" .. DV.Config.CommandPrefix .. "help'^7 pour afficher la liste des commandes disponibles.")
    
    if DV.Config.OwnerEmail == "" then
        self:print("ATTENTION", "L'email de contact n'est pas défini. Utilisez la commande '" .. DV.Config.CommandPrefix .. "email' pour le définir.", "warning")
    end
end 