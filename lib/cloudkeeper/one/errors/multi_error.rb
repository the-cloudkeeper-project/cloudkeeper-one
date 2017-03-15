module Cloudkeeper
  module One
    module Errors
      class MultiError < StandardError
        attr_accessor :errors

        def initialize
          @errors = []
        end

        def <<(error)
          @errors << error
        end

        def message
          errors.map(&:message).join('|')
        end

        def count
          errors.count
        end
      end
    end
  end
end
