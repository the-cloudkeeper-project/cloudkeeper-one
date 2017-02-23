module Cloudkeeper
  module One
    module Opennebula
      class TemplateHandler < ApplianceHandler
        def initialize
          super
          @pool = OpenNebula::TemplatePool.new client
        end

        def register(template_template, group)
          template_alloc = OpenNebula::Template.build_xml
          template = OpenNebula::Template.new(template_alloc, client)

          handle_opennebula_error { template.allocate(template_template) }

          chmod template, Cloudkeeper::One::Settings[:'appliances-permissions']
          chgrp template, group

          template
        end
      end
    end
  end
end
