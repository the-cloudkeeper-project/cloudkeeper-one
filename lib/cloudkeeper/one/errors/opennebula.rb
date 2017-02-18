module Cloudkeeper
  module One
    module Errors
      module Opennebula
        autoload :OpennebulaError, 'cloudkeeper/one/errors/opennebula/opennebula_error'
        autoload :StubError, 'cloudkeeper/one/errors/opennebula/stub_error'
        autoload :ApiCallTimeoutError, 'cloudkeeper/one/errors/opennebula/api_call_timeout_error'
        autoload :AuthenticationError, 'cloudkeeper/one/errors/opennebula/authentication_error'
        autoload :ResourceNotFoundError, 'cloudkeeper/one/errors/opennebula/resource_not_found_error'
        autoload :ResourceRetrievalError, 'cloudkeeper/one/errors/opennebula/resource_retrieval_error'
        autoload :ResourceStateError, 'cloudkeeper/one/errors/opennebula/resource_state_error'
        autoload :UserNotAuthorizedError, 'cloudkeeper/one/errors/opennebula/user_not_authorized_error'
      end
    end
  end
end
