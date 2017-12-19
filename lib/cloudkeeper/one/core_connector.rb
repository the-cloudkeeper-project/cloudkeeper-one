module Cloudkeeper
  module One
    class CoreConnector < CloudkeeperGrpc::Communicator::Service
      attr_reader :image_handler, :template_handler, :datastore_handler, :group_handler

      include Cloudkeeper::One::ApplianceActions::Registration
      include Cloudkeeper::One::ApplianceActions::Discard
      include Cloudkeeper::One::ApplianceActions::Update
      include Cloudkeeper::One::ApplianceActions::List

      ERRORS = Hash.new(CloudkeeperGrpc::Constants::STATUS_ERROR).update(
        Cloudkeeper::One::Errors::Actions::ListingError => CloudkeeperGrpc::Constants::STATUS_ERROR_APPLIANCE_NOT_FOUND,
        Cloudkeeper::One::Errors::Actions::UpdateError => CloudkeeperGrpc::Constants::STATUS_ERROR_APPLIANCE_NOT_FOUND,
        Cloudkeeper::One::Errors::NetworkConnectionError => CloudkeeperGrpc::Constants::STATUS_ERROR_APPLIANCE_TRANSFER,
        Cloudkeeper::One::Errors::Opennebula::AuthenticationError => CloudkeeperGrpc::Constants::STATUS_ERROR_AUTHENTICATION,
        Cloudkeeper::One::Errors::Opennebula::UserNotAuthorizedError => CloudkeeperGrpc::Constants::STATUS_ERROR_USER_NOT_AUTHORIZED,
        Cloudkeeper::One::Errors::Opennebula::ResourceNotFoundError => CloudkeeperGrpc::Constants::STATUS_ERROR_RESOURCE_NOT_FOUND,
        Cloudkeeper::One::Errors::Actions::RegistrationError => CloudkeeperGrpc::Constants::STATUS_ERROR_RESOURCE_NOT_FOUND,
        Cloudkeeper::One::Errors::Opennebula::ResourceRetrievalError => CloudkeeperGrpc::Constants::STATUS_ERROR_RESOURCE_RETRIEVAL,
        Cloudkeeper::One::Errors::Opennebula::ResourceStateError => CloudkeeperGrpc::Constants::STATUS_ERROR_RESOURCE_STATE,
        Cloudkeeper::One::Errors::Opennebula::ApiCallTimeoutError => CloudkeeperGrpc::Constants::STATUS_ERROR_RESOURCE_STATE
      ).freeze

      def initialize
        super

        @image_handler = Cloudkeeper::One::Opennebula::ImageHandler.new
        @template_handler = Cloudkeeper::One::Opennebula::TemplateHandler.new
        @datastore_handler = Cloudkeeper::One::Opennebula::DatastoreHandler.new
        @group_handler = Cloudkeeper::One::Opennebula::GroupHandler.new
      end

      def pre_action(_empty, call)
        logger.debug 'Running \'pre-action\'...'
        call_backend(call) { discard_expired }
      end

      def post_action(_empty, call)
        logger.debug 'Running \'post-action\'...'
        call.output_metadata['status'] = 'SUCCESS'
        Google::Protobuf::Empty.new
      end

      def add_appliance(appliance, call)
        logger.debug "Registering appliance #{appliance.identifier.inspect}"
        call_backend(call) { register_or_update_appliance appliance }
      end

      def update_appliance(appliance, call)
        logger.debug "Updating appliance #{appliance.identifier.inspect}"
        call_backend(call) { appliance.image ? register_or_update_appliance(appliance) : update_appliance_metadata(appliance) }
      end

      def remove_appliance(appliance, call)
        logger.debug "Removing appliance #{appliance.identifier.inspect}"
        call_backend(call) { discard_appliance appliance.identifier }
      end

      def remove_image_list(image_list_identifier, call)
        logger.debug "Removing appliances from image list #{image_list_identifier.image_list_identifier.inspect}"
        call_backend(call) { discard_image_list image_list_identifier.image_list_identifier }
      end

      def image_lists(_empty, call)
        logger.debug 'Retrieving image lists registered in OpenNebula'
        call_backend(call, default_return_value: [], use_return_value: true) { list_image_lists.each }
      end

      def appliances(image_list_identifier, call)
        logger.debug "Retrieving appliances from image list #{image_list_identifier.image_list_identifier.inspect} " \
                     'registered in OpenNebula'
        call_backend(call, default_return_value: [], use_return_value: true) do
          list_appliances(image_list_identifier.image_list_identifier).each
        end
      end

      private

      def call_backend(call, default_return_value: Google::Protobuf::Empty.new, use_return_value: false)
        raise Cloudkeeper::One::Errors::ArgumentError, 'Error handler was called without a block!' unless block_given?

        return_value = handle_errors(call) { yield }
        finalize_return_value(return_value, default_return_value, use_return_value)
      end

      def handle_errors(call)
        return_value = yield
        call.output_metadata[CloudkeeperGrpc::Constants::KEY_STATUS] = CloudkeeperGrpc::Constants::STATUS_SUCCESS

        return_value
      rescue Cloudkeeper::One::Errors::StandardError => ex
        logger.error "#{ex.class.inspect}: #{ex.message}"
        call.output_metadata[CloudkeeperGrpc::Constants::KEY_STATUS] = ERRORS[ex.class]
        call.output_metadata[CloudkeeperGrpc::Constants::KEY_MESSAGE] = ex.message

        return_value
      end

      def finalize_return_value(return_value, default_return_value, use_return_value)
        return return_value if return_value && use_return_value
        default_return_value
      end
    end
  end
end
