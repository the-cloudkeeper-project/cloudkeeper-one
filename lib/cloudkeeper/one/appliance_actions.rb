module Cloudkeeper
  module One
    module ApplianceActions
      autoload :Registration, 'cloudkeeper/one/appliance_actions/registration'
      autoload :Removal, 'cloudkeeper/one/appliance_actions/removal'
      autoload :Update, 'cloudkeeper/one/appliance_actions/update'
      autoload :List, 'cloudkeeper/one/appliance_actions/list'
      autoload :Utils, 'cloudkeeper/one/appliance_actions/utils'
    end
  end
end
