resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'ESX UKKORYOSTO'

version '1.0.2'

client_scripts {
  '@es_extended/locale.lua',
  'fi.lua',
  'config.lua',
  'client.lua',
  'handsup.lua'
}

server_scripts {
  '@es_extended/locale.lua',
  'fi.lua',
  'config.lua',
  'servu.lua'
}
