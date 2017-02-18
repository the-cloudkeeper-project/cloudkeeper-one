module Cloudkeeper
  module One
    module Errors
      autoload :StandardError, 'cloudkeeper/one/errors/standard_error'
      autoload :ArgumentError, 'cloudkeeper/one/errors/argument_error'

      autoload :Opennebula, 'cloudkeeper/one/errors/opennebula'
    end
  end
end
