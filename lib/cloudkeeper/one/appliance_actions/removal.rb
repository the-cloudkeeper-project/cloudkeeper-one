module Cloudkeeper
  module One
    module ApplianceActions
      module Removal
        def remove_appliance(appliance_id)
          remove_templates :find_by_appliance_id, appliance_id
          remove_images :find_by_appliance_id, appliance_id
        end

        def remove_image_list(image_list_id)
          remove_templates :find_by_image_list_id, image_list_id
          remove_images :find_by_image_list_id, image_list_id
        end

        def remove_expired
          image_handler.expired.each { |image| image_handler.delete image }
        end

        def remove_templates(method, value)
          templates = template_handler.send(method, value)
          templates.each { |template| template_handler.delete template }
        end

        def remove_images(method, value)
          images = image_handler.send(method, value)
          images.each do |image|
            image_handler.expire image
            image_handler.delete image
          end
        end
      end
    end
  end
end
