module Cloudkeeper
  module One
    module Opennebula
      class DatastoreHandler < Handler
        def initialize
          super
          @pool = OpenNebula::DatastorePool.new client
        end
      end
    end
  end
end
