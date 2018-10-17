module Cloudkeeper
  module One
    class CoreConnector < CloudkeeperGrpc::Communicator::Service
      attr_reader :image_handler, :template_handler, :datastore_handler

      include Cloudkeeper::One::ApplianceActions::Registration
      include Cloudkeeper::One::ApplianceActions::Discard
      include Cloudkeeper::One::ApplianceActions::Update
      include Cloudkeeper::One::ApplianceActions::List

      STATUS_CODES = Hash.new(CloudkeeperGrpc::Constants::STATUS_CODE_UNKNOWN).update(
        Cloudkeeper::One::Errors::Actions::ListingError => CloudkeeperGrpc::Constants::STATUS_CODE_APPLIANCE_NOT_FOUND,
        Cloudkeeper::One::Errors::Actions::UpdateError => CloudkeeperGrpc::Constants::STATUS_CODE_APPLIANCE_NOT_FOUND,
        Cloudkeeper::One::Errors::NetworkConnectionError => CloudkeeperGrpc::Constants::STATUS_CODE_FAILED_APPLIANCE_TRANSFER,
        Cloudkeeper::One::Errors::Opennebula::AuthenticationError => CloudkeeperGrpc::Constants::STATUS_CODE_UNAUTHENTICATED,
        Cloudkeeper::One::Errors::Opennebula::UserNotAuthorizedError => CloudkeeperGrpc::Constants::STATUS_CODE_PERMISSION_DENIED,
        Cloudkeeper::One::Errors::Opennebula::ResourceNotFoundError => CloudkeeperGrpc::Constants::STATUS_CODE_RESOURCE_NOT_FOUND,
        Cloudkeeper::One::Errors::Actions::RegistrationError => CloudkeeperGrpc::Constants::STATUS_CODE_RESOURCE_NOT_FOUND,
        Cloudkeeper::One::Errors::Opennebula::ResourceRetrievalError => CloudkeeperGrpc::Constants::STATUS_CODE_FAILED_RESOURCE_RETRIEVAL,
        Cloudkeeper::One::Errors::Opennebula::ResourceStateError => CloudkeeperGrpc::Constants::STATUS_CODE_INVALID_RESOURCE_STATE,
        Cloudkeeper::One::Errors::Opennebula::ApiCallTimeoutError => CloudkeeperGrpc::Constants::STATUS_CODE_INVALID_RESOURCE_STATE
      ).freeze

      def initialize
        super

        @image_handler = Cloudkeeper::One::Opennebula::ImageHandler.new
        @template_handler = Cloudkeeper::One::Opennebula::TemplateHandler.new
        @datastore_handler = Cloudkeeper::One::Opennebula::DatastoreHandler.new
      end

      def pre_action(_empty, _call)
        logger.debug 'Running \'pre-action\'...'
        Google::Protobuf::Empty.new
      end

      def post_action(_empty, _call)
        logger.debug 'Running \'post-action\'...'
        Google::Protobuf::Empty.new
      end

      def add_appliance(appliance, _call)
        logger.debug "Registering appliance #{appliance.identifier.inspect}"
        call_backend { register_or_update_appliance appliance }
      end

      def update_appliance(appliance, _call)
        logger.debug "Updating appliance #{appliance.identifier.inspect}"
        call_backend { register_or_update_appliance appliance }
      end

      def update_appliance_metadata(appliance, _call)
        logger.debug "Updating appliance metadata of #{appliance.identifier.inspect}"
        call_backend { update_metadata appliance }
      end

      def remove_appliance(appliance, _call)
        logger.debug "Removing appliance #{appliance.identifier.inspect}"
        call_backend { discard_appliance appliance.identifier }
      end

      def remove_image_list(image_list_identifier, _call)
        logger.debug "Removing appliances from image list #{image_list_identifier.image_list_identifier.inspect}"
        call_backend { discard_image_list image_list_identifier.image_list_identifier }
      end

      def image_lists(_empty, _call)
        logger.debug 'Retrieving image lists registered in OpenNebula'
        call_backend(use_return_value: true) { list_image_lists.each }
      end

      def appliances(image_list_identifier, _call)
        logger.debug "Retrieving appliances from image list #{image_list_identifier.image_list_identifier.inspect} " \
                     'registered in OpenNebula'
        call_backend(use_return_value: true) { list_appliances(image_list_identifier.image_list_identifier).each }
      end

      def remove_expired_appliances(_empty, _call)
        logger.debug 'Removing expired appliances'

        call_backend { discard_expired }
      end

      private

      def call_backend(use_return_value: false)
        raise Cloudkeeper::One::Errors::ArgumentError, 'Error handler was called without a block!' unless block_given?

        return_value = yield
        use_return_value ? return_value : Google::Protobuf::Empty.new
      rescue Cloudkeeper::One::Errors::StandardError => ex
        logger.error "#{ex.class.inspect}: #{ex.message}"
        raise GRPC::BadStatus.new(STATUS_CODES[ex.class], ex.message)
      end
    end
  end
end
