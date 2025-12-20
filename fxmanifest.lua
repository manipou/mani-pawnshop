fx_version 'cerulean'
game 'gta5'
use_fxv2_oal 'yes'

lua54 'yes'
author 'ManiMods'

ui_page 'http://localhost:5173/' -- Uncomment this if you are using Vite (live preview when developing)
-- ui_page 'web/build/index.html'

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua',
    '@oxmysql/lib/MySQL.lua',
    'sv_util.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
}

files {
    'config.lua',
    'util.lua',
    'web/build/index.html',
    'web/build/**/*'
}