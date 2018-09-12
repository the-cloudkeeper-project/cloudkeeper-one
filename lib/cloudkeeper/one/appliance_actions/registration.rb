module Cloudkeeper
  module One
    module ApplianceActions
      module Registration
        include Utils::ImageDownload
        include Utils::TemplatePreparation
        include Cloudkeeper::One::ApplianceActions::Update
        include Cloudkeeper::One::ApplianceActions::Discard

        def register_or_update_appliance(proto_appliance)
          raise Cloudkeeper::One::Errors::ArgumentError, 'appliance cannot be nil' unless proto_appliance

          group_name = Cloudkeeper::One::Settings[:public] ? Cloudkeeper::One::Settings[:'opennebula-public-group'] : proto_appliance.vo
          group = group_handler.find_by_name group_name
          raise Cloudkeeper::One::Errors::Actions::RegistrationError, "Missing group with name #{group_name}" unless group

          discard_images :find_by_appliance_id, proto_appliance.identifier

          datastores = datastore_handler.find_by_names Cloudkeeper::One::Settings[:'opennebula-datastores']
          datastores.each do |datastore|
            image = register_image proto_appliance, datastore, group
            register_or_update_template proto_appliance, image, group
          end
        end

        private

        def register_or_update_template(proto_appliance, image, group)
          template = template_handler.find_by_name image.name
          if template
            update_template template, image, proto_appliance
            return
          end

          register_template proto_appliance, image.id, image.name, group
        end

        def register_image(proto_appliance, datastore, group)
          raise Cloudkeeper::One::Errors::ArgumentError, 'appliance and image cannot be nil' \
            unless proto_appliance && proto_appliance.image

          logger.debug "Registering image for appliance #{proto_appliance.identifier}, datastore #{datastore.name.inspect} and " \
                       "group #{group.name.inspect}"

          proto_image = prepare_image proto_appliance
          name = "#{proto_appliance.identifier}@#{datastore.name}"
          template = prepare_template 'image.erb', appliance: proto_appliance, image: proto_image, name: name
          image_handler.register template, datastore, group
        end

        def register_template(proto_appliance, image_id, name, group)
          raise Cloudkeeper::One::Errors::ArgumentError, 'appliance cannot be nil' \
            unless proto_appliance

          logger.debug "Registering template for appliance #{proto_appliance.identifier}, image #{image_id.inspect} and " \
                       "group #{group.name.inspect}"

          proto_image = proto_appliance.image
          template = prepare_template 'template.erb', appliance: proto_appliance, image: proto_image,
                                                      name: name, image_id: image_id
          template_handler.register template, group
        end

        def prepare_image(proto_appliance)
          proto_image = proto_appliance.image
          proto_image.location = download_image(proto_image.location, proto_image.username, proto_image.password) \
            if proto_image.mode == :REMOTE

          proto_image
        end
      end
    end
  end
end
