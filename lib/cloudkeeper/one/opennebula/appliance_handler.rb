require 'timeout'

module Cloudkeeper
  module One
    module Opennebula
      class ApplianceHandler < Handler
        attr_reader :identifier

        LEAVE_ID_AS_IS = -1
        ONEADMIN_ID = 0

        def initialize
          super

          @identifier = Cloudkeeper::One::Settings[:identifier]
        end

        def list(appliance_id)
          xpaths = { "TEMPLATE/#{Tags::APPLIANCE_ID}" => appliance_id }
          xpaths['UNAME'] = Cloudkeeper::One::Settings[:'opennebula-users'] \
            if Cloudkeeper::One::Settings[:'opennebula-users'] && !Cloudkeeper::One::Settings[:'opennebula-users'].empty?

          find_all xpaths
        end

        def delete(element)
          raise Cloudkeeper::One::Errors::ArgumentError, 'element cannot be nil' unless element

          id = element.id
          handle_opennebula_error { element.delete }

          timeout { sleep(Cloudkeeper::One::Opennebula::Handler::API_POLLING_WAIT) while exist? id }
        end

        def chmod(element, permissions)
          handle_opennebula_error { element.chmod_octet permissions }
        end

        def chgrp(element, group)
          handle_opennebula_error { element.info! }
          group_id = group.id == element.gid ? LEAVE_ID_AS_IS : group.id
          handle_opennebula_error { element.chown(LEAVE_ID_AS_IS, group_id) }
        end

        private

        def timeout
          Timeout.timeout(Cloudkeeper::One::Settings[:'opennebula-api-call-timeout']) { yield }
        rescue Timeout::Error
          raise Cloudkeeper::One::Errors::Opennebula::ApiCallTimeoutError, 'Operation was not successful within the timeout'
        end

        def find(method, xpaths = {})
          reload!

          pool.send(method) { |element| element["TEMPLATE/#{Tags::ID}"] == identifier && evaluate_xpaths(element, xpaths) }
        end
      end
    end
  end
end
