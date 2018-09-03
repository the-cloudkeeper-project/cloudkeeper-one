module Cloudkeeper
  module One
    module Opennebula
      module Tags
        BASE = 'CLOUDKEEPER'.freeze
        APPLIANCE = "#{BASE}_APPLIANCE".freeze
        IMAGE = "#{BASE}_IMAGE".freeze

        ID = "#{BASE}_ID".freeze
        EXPIRED = "#{BASE}_EXPIRED".freeze

        APPLIANCE_ID = "#{APPLIANCE}_ID".freeze
        APPLIANCE_TITLE = "#{APPLIANCE}_TITLE".freeze
        APPLIANCE_DESCRIPTION = "#{APPLIANCE}_DESCRIPTION".freeze
        APPLIANCE_MPURI = "#{APPLIANCE}_MPURI".freeze
        APPLIANCE_GROUP = "#{APPLIANCE}_GROUP".freeze
        APPLIANCE_RAM = "#{APPLIANCE}_RAM".freeze
        APPLIANCE_CORE = "#{APPLIANCE}_CORE".freeze
        APPLIANCE_VERSION = "#{APPLIANCE}_VERSION".freeze
        APPLIANCE_ARCHITECTURE = "#{APPLIANCE}_ARCHITECTURE".freeze
        APPLIANCE_OPERATING_SYSTEM = "#{APPLIANCE}_OPERATING_SYSTEM".freeze
        APPLIANCE_VO = "#{APPLIANCE}_VO".freeze
        APPLIANCE_EXPIRATION_DATE = "#{APPLIANCE}_EXPIRATION_DATE".freeze
        APPLIANCE_IMAGE_LIST_ID = "#{APPLIANCE}_IMAGE_LIST_ID".freeze
        APPLIANCE_BASE_MPURI = "#{APPLIANCE}_BASE_MPURI".freeze
        APPLIANCE_APPID = "#{APPLIANCE}_APPID".freeze
        APPLIANCE_DIGEST = "#{APPLIANCE}_DIGEST".freeze

        IMAGE_URI = "#{IMAGE}_URI".freeze
        IMAGE_CHECKSUM = "#{IMAGE}_CHECKSUM".freeze
        IMAGE_SIZE = "#{IMAGE}_SIZE".freeze
        IMAGE_FORMAT = "#{IMAGE}_FORMAT".freeze
        IMAGE_DIGEST = "#{IMAGE}_DIGEST".freeze
      end
    end
  end
end
