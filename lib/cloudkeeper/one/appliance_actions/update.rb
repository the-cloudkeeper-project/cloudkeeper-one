module Cloudkeeper
  module One
    module ApplianceActions
      module Update
        include Utils::TemplatePreparation

        def update_appliance_metadata(proto_appliance)
          raise Cloudkeeper::One::Errors::ArgumentError, 'appliance cannot be nil' unless proto_appliance

          templates = template_handler.find_by_appliance_id proto_appliance.identifier
          templates.each do |template|
            image = image_handler.find_by_name template.name
            raise Cloudkeeper::One::Errors::Actions::UpdateError, "Missing coresponding image for template #{template.id.inspect}"\
              unless image
            update_image image, proto_appliance
            update_template template, image, proto_appliance
          end
        end

        def update_image(image, proto_appliance)
          logger.debug "Updating image metadata for appliance #{proto_appliance.identifier.inspect}"
          image_template = prepare_template 'image.erb', appliance: proto_appliance, name: image.name
          image_handler.update image, image_template
        end

        def update_template(template, image, proto_appliance)
          logger.debug "Updating template metadata for appliance #{proto_appliance.identifier.inspect}"
          template_template = prepare_template 'template.erb', appliance: proto_appliance, name: template.name, image_id: image.id
          template_handler.update template, template_template
        end
      end
    end
  end
end
