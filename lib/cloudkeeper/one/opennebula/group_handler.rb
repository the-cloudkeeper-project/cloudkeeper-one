module Cloudkeeper
  module One
    module Opennebula
      class GroupHandler < Handler
        def initialize
          super
          @pool = OpenNebula::GroupPool.new client
        end
      end
    end
  end
end
