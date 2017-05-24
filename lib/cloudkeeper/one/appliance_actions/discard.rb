module Cloudkeeper
  module One
    module ApplianceActions
      module Discard
        def discard_appliance(appliance_id)
          logger.debug "Removing templates for appliance #{appliance_id.inspect}"
          discard_templates :find_by_appliance_id, appliance_id
          logger.debug "Removing images for appliance #{appliance_id.inspect}"
          discard_images :find_by_appliance_id, appliance_id
        end

        def discard_image_list(image_list_id)
          logger.debug "Removing templates for image list #{image_list_id.inspect}"
          discard_templates :find_by_image_list_id, image_list_id
          logger.debug "Removing images for image list #{image_list_id.inspect}"
          discard_images :find_by_image_list_id, image_list_id
        end

        def discard_expired
          logger.debug 'Removing expired images...'
          handle_iteration(image_handler.expired) { |item| image_handler.delete item }
        end

        def discard_templates(method, value)
          handle_iteration(template_handler.send(method, value)) { |item| template_handler.delete item }
        end

        def discard_images(method, value)
          handle_iteration(image_handler.send(method, value)) do |item|
            image_handler.expire item
            image_handler.delete item
          end
        end

        private

        def handle_iteration(items)
          raise Cloudkeeper::One::Errors::ArgumentError, 'Iteration error handler was called without a block!' unless block_given?

          error = nil
          items.each do |item|
            begin
              yield item
            rescue Cloudkeeper::One::Errors::StandardError => ex
              error ||= Cloudkeeper::One::Errors::MultiError.new
              error << ex
              logger.error ex.message
              next
            end
          end

          raise error if error
        end
      end
    end
  end
end
