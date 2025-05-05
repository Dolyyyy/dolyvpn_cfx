fx_version "adamant"

games {'rdr3'}
author 'Doly'
description 'DolyVpn - Login System with VPN/Proxy detection'
version '1.0.0'

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

server_scripts {
    'config.lua',
    'init.lua',
}

files {
    'classes/*.lua',
    'modules/*.lua'
}
