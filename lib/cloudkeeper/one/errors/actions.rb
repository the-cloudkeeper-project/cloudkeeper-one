module Cloudkeeper
  module One
    module Errors
      module Actions
        autoload :ActionError, 'cloudkeeper/one/errors/actions/action_error'
        autoload :RegistrationError, 'cloudkeeper/one/errors/actions/registration_error'
        autoload :ListingError, 'cloudkeeper/one/errors/actions/listing_error'
      end
    end
  end
end
