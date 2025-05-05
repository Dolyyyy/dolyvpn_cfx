--[[
    Module Discord
    Gère l'intégration avec Discord via webhook
]]

DV.Discord = {}

-- Envoyer un message à Discord via webhook
function DV.Discord:sendLog(title, description, color, ping)
    if not DV.Config.EnableDiscordLogs or DV.Config.DiscordWebhook == '' then return end
    
    local embed = {
        {
            ["title"] = title,
            ["description"] = description,
            ["type"] = "rich",
            ["color"] = color or 3447003, -- Bleu par défaut
            ["footer"] = {
                ["text"] = DV.Config.ProjectName .. " | " .. os.date("%d/%m/%Y %H:%M:%S")
            }
        }
    }
    
    local content = ""
    if ping then
        content = "<@" .. DV.Config.AdminDiscordID .. ">"
    end
    
    PerformHttpRequest(DV.Config.DiscordWebhook, function(err, text, headers) end, 'POST', json.encode({
        username = DV.Config.ProjectName,
        embeds = embed,
        content = content,
        avatar_url = "https://png.pngtree.com/png-vector/20220914/ourmid/pngtree-no-vpnanonymizer-service-allowed-character-exclusion-red-vector-png-image_39227264.png"
    }), { ['Content-Type'] = 'application/json' })
end 