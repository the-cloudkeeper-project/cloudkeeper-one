module Cloudkeeper
  module One
    class CoreConnector < CloudkeeperGrpc::Communicator::Service
      def pre_action(_empty, _unused_call)
        raise NotImplementedError, 'this call is not implemented yet'
      end

      def post_action(_empty, _unused_call)
        raise NotImplementedError, 'this call is not implemented yet'
      end

      def add_appliance(_appliance, _unused_call)
        raise NotImplementedError, 'this call is not implemented yet'
      end

      def update_appliance(_empty, _unused_call)
        raise NotImplementedError, 'this call is not implemented yet'
      end

      def remove_appliance(_empty, _unused_call)
        raise NotImplementedError, 'this call is not implemented yet'
      end

      def remove_image_list(_empty, _unused_call)
        raise NotImplementedError, 'this call is not implemented yet'
      end

      def image_lists(_empty, _unused_call)
        raise NotImplementedError, 'this call is not implemented yet'
      end

      def appliances(_empty, _unused_call)
        raise NotImplementedError, 'this call is not implemented yet'
      end
    end
  end
end
