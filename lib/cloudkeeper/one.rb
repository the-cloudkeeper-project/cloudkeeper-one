require 'active_support/all'

module Cloudkeeper
  module One
    autoload :Version, 'cloudkeeper/one/version'
    autoload :CLI, 'cloudkeeper/one/cli'
    autoload :Settings, 'cloudkeeper/one/settings'
    autoload :CoreConnector, 'cloudkeeper/one/core_connector'
  end
end
