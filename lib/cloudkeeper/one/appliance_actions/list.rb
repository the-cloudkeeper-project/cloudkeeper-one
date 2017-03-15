module Cloudkeeper
  module One
    module ApplianceActions
      module List
        def list_image_lists
          logger.debug 'Listing all image lists available in OpenNebula'
          template_handler.find_all.map do |template|
            image_list_identifier = template["TEMPLATE/#{Cloudkeeper::One::Opennebula::Tags::APPLIANCE_IMAGE_LIST_ID}"]
            unless image_list_identifier
              logger.warn "Managed template #{template.id.inspect} is missing image list identifier"
              next
            end
            CloudkeeperGrpc::ImageListIdentifier.new image_list_identifier: image_list_identifier
          end.compact.uniq(&:image_list_identifier).sort_by(&:image_list_identifier)
        end

        def list_appliances(image_list_id)
          logger.debug "Listing appliances with image list id #{image_list_id.inspect}"
          templates = template_handler.find_by_image_list_id image_list_id
          templates.uniq! { |template| template["TEMPLATE/#{Cloudkeeper::One::Opennebula::Tags::APPLIANCE_ID}"] }

          templates.map do |template|
            image = find_image_for_template template
            populate_proto_appliance template, image
          end
        end

        private

        def find_image_for_template(template)
          image = image_handler.find_by_name template.name
          raise Cloudkeeper::One::Errors::Actions::ListingError, "Missing coresponding image for template #{template.id.inspect}" \
            unless image
          image
        end

        def populate_proto_appliance(template, image)
          CloudkeeperGrpc::Appliance.new identifier: template["TEMPLATE/#{Cloudkeeper::One::Opennebula::Tags::APPLIANCE_ID}"].to_s,
                                         description: template["TEMPLATE/#{Cloudkeeper::One::Opennebula::Tags::APPLIANCE_DESCRIPTION}"].to_s,
                                         mpuri: template["TEMPLATE/#{Cloudkeeper::One::Opennebula::Tags::APPLIANCE_MPURI}"].to_s,
                                         title: template["TEMPLATE/#{Cloudkeeper::One::Opennebula::Tags::APPLIANCE_TITLE}"].to_s,
                                         group: template["TEMPLATE/#{Cloudkeeper::One::Opennebula::Tags::APPLIANCE_GROUP}"].to_s,
                                         ram: template["TEMPLATE/#{Cloudkeeper::One::Opennebula::Tags::APPLIANCE_RAM}"].to_i,
                                         core: template["TEMPLATE/#{Cloudkeeper::One::Opennebula::Tags::APPLIANCE_CORE}"].to_i,
                                         version: template["TEMPLATE/#{Cloudkeeper::One::Opennebula::Tags::APPLIANCE_VERSION}"].to_s,
                                         architecture: template["TEMPLATE/#{Cloudkeeper::One::Opennebula::Tags::APPLIANCE_ARCHITECTURE}"].to_s,
                                         operating_system: template["TEMPLATE/#{Cloudkeeper::One::Opennebula::Tags::APPLIANCE_OPERATING_SYSTEM}"].to_s,
                                         vo: template["TEMPLATE/#{Cloudkeeper::One::Opennebula::Tags::APPLIANCE_VO}"].to_s,
                                         image: populate_proto_image(image),
                                         expiration_date: template["TEMPLATE/#{Cloudkeeper::One::Opennebula::Tags::APPLIANCE_EXPIRATION_DATE}"].to_i,
                                         image_list_identifier: template["TEMPLATE/#{Cloudkeeper::One::Opennebula::Tags::APPLIANCE_IMAGE_LIST_ID}"].to_s,
                                         attributes: JSON.parse(Base64.strict_decode64(template["TEMPLATE/#{Cloudkeeper::One::Opennebula::Tags::APPLIANCE_ATTRIBUTES}"]))
        end

        def populate_proto_image(image)
          CloudkeeperGrpc::Image.new mode: :LOCAL, location: '',
                                     format: image["TEMPLATE/#{Cloudkeeper::One::Opennebula::Tags::IMAGE_FORMAT}"].upcase.to_sym,
                                     checksum: image["TEMPLATE/#{Cloudkeeper::One::Opennebula::Tags::IMAGE_CHECKSUM}"].to_s,
                                     size: image["TEMPLATE/#{Cloudkeeper::One::Opennebula::Tags::IMAGE_SIZE}"].to_i,
                                     uri: image["TEMPLATE/#{Cloudkeeper::One::Opennebula::Tags::IMAGE_URI}"].to_s
        end
      end
    end
  end
end
