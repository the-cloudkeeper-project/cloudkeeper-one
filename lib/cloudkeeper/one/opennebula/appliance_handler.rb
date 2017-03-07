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

        def find_by_appliance_id(appliance_id)
          find_all_by "TEMPLATE/#{Tags::APPLIANCE_ID}" => appliance_id
        end

        def find_by_image_list_id(image_list_id)
          find_all_by "TEMPLATE/#{Tags::APPLIANCE_IMAGE_LIST_ID}" => image_list_id
        end

        def delete(element)
          raise Cloudkeeper::One::Errors::ArgumentError, 'element cannot be nil' unless element

          id = element.id
          handle_opennebula_error { element.delete }

          timeout { sleep(Cloudkeeper::One::Opennebula::Handler::API_POLLING_WAIT) while exist? id }
        end

        def chmod(element, permissions)
          raise Cloudkeeper::One::Errors::ArgumentError, 'element cannot be nil' unless element

          handle_opennebula_error do
            element.chmod_octet permissions
            element.info!
          end
        end

        def update(element, template)
          raise Cloudkeeper::One::Errors::ArgumentError, 'element cannot be nil' unless element

          handle_opennebula_error do
            element.update template, true
            element.info!
          end
        end

        def chgrp(element, group)
          raise Cloudkeeper::One::Errors::ArgumentError, 'element cannot be nil' unless element

          handle_opennebula_error { element.info! }
          return if group.id == element.gid

          handle_opennebula_error do
            element.chown(LEAVE_ID_AS_IS, group.id)
            element.info!
          end
        end

        private

        def find_all_by(attributes)
          xpaths = attributes.clone
          xpaths['UNAME'] = Cloudkeeper::One::Settings[:'opennebula-users'] \
            if Cloudkeeper::One::Settings[:'opennebula-users'] && !Cloudkeeper::One::Settings[:'opennebula-users'].empty?

          find_all xpaths
        end

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
