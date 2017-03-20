module Cloudkeeper
  module One
    class CoreConnector < CloudkeeperGrpc::Communicator::Service
      attr_reader :image_handler, :template_handler, :datastore_handler, :group_handler

      include Cloudkeeper::One::ApplianceActions::Registration
      include Cloudkeeper::One::ApplianceActions::Removal
      include Cloudkeeper::One::ApplianceActions::Update
      include Cloudkeeper::One::ApplianceActions::List

      ERRORS = Hash.new(:ERROR).update(Cloudkeeper::One::Errors::Actions::ListingError => :ERROR_APPLIANCE_NOT_FOUND,
                                       Cloudkeeper::One::Errors::Actions::UpdateError => :ERROR_APPLIANCE_NOT_FOUND,
                                       Cloudkeeper::One::Errors::NetworkConnectionError => :ERROR_APPLIANCE_TRANSFER,
                                       Cloudkeeper::One::Errors::Opennebula::AuthenticationError => :ERROR_AUTHENTICATION,
                                       Cloudkeeper::One::Errors::Opennebula::UserNotAuthorizedError => :ERROR_USER_NOT_AUTHORIZED,
                                       Cloudkeeper::One::Errors::Opennebula::ResourceNotFoundError => :ERROR_RESOURCE_NOT_FOUND,
                                       Cloudkeeper::One::Errors::Actions::RegistrationError => :ERROR_RESOURCE_NOT_FOUND,
                                       Cloudkeeper::One::Errors::Opennebula::ResourceRetrievalError => :ERROR_RESOURCE_RETRIEVAL,
                                       Cloudkeeper::One::Errors::Opennebula::ResourceStateError => :ERROR_RESOURCE_STATE,
                                       Cloudkeeper::One::Errors::Opennebula::ApiCallTimeoutError => :ERROR_RESOURCE_STATE).freeze

      def initialize
        super

        @image_handler = Cloudkeeper::One::Opennebula::ImageHandler.new
        @template_handler = Cloudkeeper::One::Opennebula::TemplateHandler.new
        @datastore_handler = Cloudkeeper::One::Opennebula::DatastoreHandler.new
        @group_handler = Cloudkeeper::One::Opennebula::GroupHandler.new
      end

      def pre_action(_empty, _unused_call)
        logger.debug 'Running \'pre-action\'...'
        handle_errors { remove_expired }
      end

      def post_action(_empty, _unused_call)
        logger.debug 'Running \'post-action\'...'
        CloudkeeperGrpc::Status.new(code: :SUCCESS, message: '')
      end

      def add_appliance(appliance, _unused_call)
        logger.debug "Registering appliance #{appliance.identifier.inspect}"
        handle_errors { register_or_update_appliance appliance }
      end

      def update_appliance(appliance, _unused_call)
        logger.debug "Updating appliance #{appliance.identifier.inspect}"
        handle_errors { appliance.image ? register_or_update_appliance(appliance) : update_appliance_metadata(appliance) }
      end

      def remove_appliance(appliance, _unused_call)
        logger.debug "Removing appliance #{appliance.identifier.inspect}"
        handle_errors { remove_appliance appliance }
      end

      def remove_image_list(image_list_identifier, _unused_call)
        logger.debug "Removing appliances from image list #{image_list_identifier.image_list_identifier.inspect}"
        handle_errors { remove_image_list image_list_identifier.image_list_identifier }
      end

      def image_lists(_empty, _unused_call)
        logger.debug 'Retrieving image lists registered in OpenNebula'
        list_image_lists.each
      end

      def appliances(image_list_identifier, _unused_call)
        logger.debug "Retrieving appliances from image list #{image_list_identifier.image_list_identifier.inspect} " \
                     'registered in OpenNebula'
        list_appliances(image_list_identifier.image_list_identifier).each
      end

      private

      def handle_errors
        raise Cloudkeeper::One::Errors::ArgumentError, 'Error handler was called without a block!' unless block_given?

        yield
        CloudkeeperGrpc::Status.new(code: :SUCCESS, message: '')
      rescue Cloudkeeper::One::Errors::StandardError => ex
        CloudkeeperGrpc::Status.new(code: ERRORS[ex.class], message: ex.message)
      end
    end
  end
end
