require 'active_support/all'
require 'opennebula'

module Cloudkeeper
  module One
    autoload :Errors, 'cloudkeeper/one/errors'
    autoload :Opennebula, 'cloudkeeper/one/opennebula'

    autoload :Version, 'cloudkeeper/one/version'
    autoload :CLI, 'cloudkeeper/one/cli'
    autoload :Settings, 'cloudkeeper/one/settings'
    autoload :CoreConnector, 'cloudkeeper/one/core_connector'
  end
end
