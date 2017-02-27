require 'active_support/all'
require 'opennebula'
require 'json'
require 'base64'
require 'tempfile'

module Cloudkeeper
  module One
    autoload :Errors, 'cloudkeeper/one/errors'
    autoload :Opennebula, 'cloudkeeper/one/opennebula'
    autoload :ApplianceActions, 'cloudkeeper/one/appliance_actions'

    autoload :Version, 'cloudkeeper/one/version'
    autoload :CLI, 'cloudkeeper/one/cli'
    autoload :Settings, 'cloudkeeper/one/settings'
    autoload :CoreConnector, 'cloudkeeper/one/core_connector'
  end
end
