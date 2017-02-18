module Cloudkeeper
  module One
    module Opennebula
      module Helper
        ERRORS = Hash.new(Cloudkeeper::One::Errors::Opennebula::ResourceRetrievalError)
                     .update(::OpenNebula::Error::EAUTHENTICATION => Cloudkeeper::One::Errors::Opennebula::AuthenticationError,
                             ::OpenNebula::Error::EAUTHORIZATION => Cloudkeeper::One::Errors::Opennebula::UserNotAuthorizedError,
                             ::OpenNebula::Error::ENO_EXISTS => Cloudkeeper::One::Errors::Opennebula::ResourceNotFoundError,
                             ::OpenNebula::Error::EACTION => Cloudkeeper::One::Errors::Opennebula::ResourceStateError).freeze

        def handle_opennebula_error
          raise Cloudkeeper::One::Errors::Opennebula::StubError, 'OpenNebula service-wrapper was called without a block!' \
            unless block_given?

          return_value = yield
          return return_value unless OpenNebula.is_error?(return_value)

          raise decode_error(return_value.errno), return_value.message
        end

        def decode_error(errno)
          ERRORS[errno]
        end
      end
    end
  end
end
