Config = {}

-- Configuration générale
Config.ProjectName = 'DolyVPN' -- Nom du projet
Config.CommandPrefix = 'doly' -- Préfixe des commandes
Config.HelpCommand = Config.CommandPrefix .. 'help' -- Commande d'aide
Config.OwnerEmail = 'mail@gmail.com' -- Email de contact pour GetIPIntel (obligatoire)
Config.KickThreshold = 0.95 -- Seuil de détection (0.99 recommandé)
Config.Flags = 'm' -- Options de vérification (m = plus rapide et précis)
Config.KickReason = "Nous avons détecté que vous utilisez un VPN ou Proxy. Si vous pensez qu'il s'agit d'une erreur, veuillez contacter l'équipe d'administration en faisant un ticket sur notre discord : ..." -- Message affiché lors du kick
Config.PrintFailed = true -- Afficher les connexions bloquées dans la console
Config.CacheTime = 28800 -- Durée de mise en cache des IPs (en secondes)
Config.Enabled = true -- Activer/désactiver la protection
Config.WhitelistEnabled = false -- Activer/désactiver la whitelist
Config.ISPVerificationEnabled = true -- Activer/désactiver la vérification de l'ISP
Config.WhitelistMessage = "La whitelist est activée sur ce serveur. Vous n'êtes pas sur la liste des joueurs autorisés." -- Message affiché lors du refus d'accès par whitelist

-- Configuration Discord
Config.DiscordWebhook = 'https://discord.com/api/webhooks/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' -- URL du webhook Discord pour les logs
Config.AdminDiscordID = '464356448231489546' -- ID Discord de l'administrateur à mentionner en cas d'erreur critique
Config.EnableDiscordLogs = true -- Activer/désactiver les logs Discord

-- Liste des IDs Discord autorisés à bypasser la vérification
Config.WhitelistedDiscords = {
    "464356448231489546",
}

-- Liste des IPs blacklistées
Config.BlacklistedIPs = {
}

-- Liste des opérateurs légitimes (ne seront pas considérés comme VPN)
Config.LegitimateISPs = {
    "Free",
    "SFR",
    "Bouygues Telecom",
    "La Poste Mobile",
    "Coriolis Télécom",
    "Nordnet",
    "OVH Télécom",
    "FDN",
    "Proximus",
    "Telenet",
    "Voo",
    "Mobile Vikings",
    "Bell Canada",
    "Rogers Communications",
    "Telus",
    "Shaw Communications",
    "Videotron",
    "Swisscom",
    "Sunrise",
    "Salt",
    "Quickline",
    "Wingo",
    "Init7",
    "Green.ch",
    "Luxnet",
    "Post Luxembourg",
    "Tango",
    "Ziggo",
    "EstNOC OY",
    "Blade",
    "Shadow",
    "Orange",
    "Vem",
    "France Telecom",
}

-- Mots-clés typiques des fournisseurs de VPN/Proxy
Config.VPNKeywords = {
    "vpn",
    "proxy",
    "hosting",
    "host",
    "cloud",
    "server",
    "data center",
    "datacenter",
    "dedicated",
    "solutions",
    "anonymous",
    "tor",
    "exit",
    "relay",
    "node",
    "private",
    "hide",
    "mask",
    "secure",
    "security",
    "protect",
    "protection",
    "privacy",
    "private network",
    "tunnel",
    "nordvpn",
    "expressvpn",
    "cyberghost",
    "surfshark",
    "protonvpn",
    "ipvanish",
    "purevpn",
    "mullvad",
    "windscribe",
    "torguard",
    "privatevpn",
    "vyprvpn",
    "hotspotshield",
    "strongvpn",
    "privatetunnel",
    "hidemyass",
    "zenmate",
    "tunnelbear",
    "avast",
    "kaspersky",
    "norton",
    "mcafee",
    "bitdefender",
    "avira",
    "f-secure",
    "eset",
    "panda",
    "bullguard",
    "webroot",
    "sophos",
    "trend micro",
    "symantec",
    "aws",
    "amazon",
    "azure",
    "microsoft",
    "google cloud",
    "gcp",
    "digitalocean",
    "linode",
    "vultr",
    "ovh",
    "hetzner",
    "scaleway",
    "oracle",
    "ibm",
    "alibaba",
    "tencent",
    "baidu",
    "huawei",
    "cloudflare",
}
