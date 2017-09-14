require 'middleman-core'

Middleman::Extensions.register :google_tag_manager do
  require 'middleman-google-tag-manager/extension'
  GoogleTagManager
end
