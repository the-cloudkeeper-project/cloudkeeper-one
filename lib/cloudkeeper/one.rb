require 'active_support/all'
require 'opennebula'
require 'json'
require 'base64'

module Cloudkeeper
  module One
    autoload :Errors, 'cloudkeeper/one/errors'
    autoload :Opennebula, 'cloudkeeper/one/opennebula'
    autoload :ApplianceActions, 'cloudkeeper/one/appliance_actions'

    autoload :CLI, 'cloudkeeper/one/cli'
    autoload :Settings, 'cloudkeeper/one/settings'
    autoload :CoreConnector, 'cloudkeeper/one/core_connector'
  end
end

require 'cloudkeeper/one/version'
