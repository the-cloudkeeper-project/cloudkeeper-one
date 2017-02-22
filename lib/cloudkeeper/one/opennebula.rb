module Cloudkeeper
  module One
    module Opennebula
      autoload :Helper, 'cloudkeeper/one/opennebula/helper'
      autoload :Tags, 'cloudkeeper/one/opennebula/tags'
      autoload :Handler, 'cloudkeeper/one/opennebula/handler'
      autoload :DatastoreHandler, 'cloudkeeper/one/opennebula/datastore_handler'
      autoload :GroupHandler, 'cloudkeeper/one/opennebula/group_handler'
      autoload :ApplianceHandler, 'cloudkeeper/one/opennebula/appliance_handler'
      autoload :ImageHandler, 'cloudkeeper/one/opennebula/image_handler'
      autoload :TemplateHandler, 'cloudkeeper/one/opennebula/template_handler'
    end
  end
end
