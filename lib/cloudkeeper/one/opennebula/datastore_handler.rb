module Cloudkeeper
  module One
    module Opennebula
      class DatastoreHandler < Handler
        def initialize
          super
          @pool = OpenNebula::DatastorePool.new client
        end

        def find_by_names(names)
          names.map { |name| find_by_name name }.compact
        end
      end
    end
  end
end
