module Cloudkeeper
  module One
    module ApplianceActions
      module Update
        include Utils::TemplatePreparation

        def update_appliance_metadata(proto_appliance)
          templates = template_handler.find_by_appliance_id proto_appliance.identifier
          templates.each do |template|
            image = image_handler.find_by_name template.name
            update_image image, proto_appliance
            update_template template, image, proto_appliance
          end
        end

        def update_image(image, proto_appliance)
          image_template = prepare_template 'image.erb', appliance: proto_appliance, name: image.name
          image_handler.update image, image_template
        end

        def update_template(template, image, proto_appliance)
          template_template = prepare_template 'template.erb', appliance: proto_appliance, name: template.name, image_id: image.id
          template_handler.update template, template_template
        end
      end
    end
  end
end
