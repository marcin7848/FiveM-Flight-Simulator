fx_version 'adamant'
games { 'gta5' };

name 'vMenu'
description 'vMenu'

contributor {
    'Tom Grobbe'
};

files {
    'Newtonsoft.Json.dll',
    'MenuAPI.dll',
    'config/locations.json',
    'config/addons.json',
}

client_scripts {
    "vMenuClient.net.dll"
}

server_scripts {
    "vMenuServer.net.dll"
}