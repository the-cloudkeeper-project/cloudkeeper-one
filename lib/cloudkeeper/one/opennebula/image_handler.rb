module Cloudkeeper
  module One
    module Opennebula
      class ImageHandler < ApplianceHandler
        IMAGE_STATES = {
          ready: 'READY',
          used: 'USED',
          disabled: 'DISABLED',
          error: 'ERROR'
        }.freeze

        EXPIRED_PERMISSIONS = '600'.freeze

        def initialize
          super
          @pool = OpenNebula::ImagePool.new client
        end

        def expired
          xpaths = { "TEMPLATE/#{Tags::EXPIRED}" => 'yes' }

          find_all xpaths
        end

        def delete(image)
          raise Cloudkeeper::One::Errors::ArgumentError, 'image cannot be nil' unless image

          id = image.id

          if used? image
            logger.warn "Image with id #{id.inspect} cannot be removed, still in use"
            return
          end

          super image
        end

        def disable(image)
          raise Cloudkeeper::One::Errors::ArgumentError, 'image cannot be nil' unless image

          id = image.id

          if disabled? image
            logger.info "Image with id #{id.inspect} is already disabled, skipping"
            return
          end

          unless free? image
            logger.warn "Image with id #{id.inspect} cannot be disabled"
            return
          end

          handle_opennebula_error { image.disable }

          timeout { sleep(Cloudkeeper::One::Opennebula::Handler::API_POLLING_WAIT) until disabled? image }
        end

        def expire(image)
          raise Cloudkeeper::One::Errors::ArgumentError, 'image cannot be nil' unless image

          id = image.id

          if expired? image
            logger.debug("Image with id #{id.inspect} is already expired, skipping")
            return
          end

          chmod image, EXPIRED_PERMISSIONS
          disable image

          expiration_attribute = "#{Tags::EXPIRED} = \"yes\""

          handle_opennebula_error { image.rename("EXPIRED_#{Time.now.to_i}_#{image.name}") }
          handle_opennebula_error { image.update(expiration_attribute, true) }
        end

        def register(image_template, datastore)
          image_alloc = OpenNebula::Image.build_xml
          image = OpenNebula::Image.new(image_alloc, client)

          handle_opennebula_error { image.allocate(image_template, datastore.id) }

          timeout do
            until ready? image
              if error? image
                delete image
                raise Cloudkeeper::One::Errors::Opennebula::ResourceStateError, image['TEMPLATE/ERROR']
              end
              sleep(Cloudkeeper::One::Opennebula::Handler::API_POLLING_WAIT)
            end
          end

          chmod image, Cloudkeeper::One::Settings[:'appliances-permissions']

          image
        end

        def expired?(image)
          is?(image) { image["TEMPLATE/#{Tags::EXPIRED}"] == 'yes' }
        end

        def disabled?(image)
          is?(image) { image.state_str == IMAGE_STATES[:disabled] }
        end

        def ready?(image)
          is?(image) { image.state_str == IMAGE_STATES[:ready] }
        end

        def used?(image)
          is?(image) { image.state_str == IMAGE_STATES[:used] }
        end

        def free?(image)
          is?(image) { image.state_str == IMAGE_STATES[:ready] || image.state_str == IMAGE_STATES[:error] }
        end

        def error?(image)
          is?(image) { image.state_str == IMAGE_STATES[:error] }
        end

        private

        def is?(image)
          raise Cloudkeeper::One::Errors::ArgumentError, 'image cannot be nil' unless image

          handle_opennebula_error { image.info! }
          yield
        end
      end
    end
  end
end
