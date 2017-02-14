require 'settingslogic'

module Cloudkeeper
  module One
    class Settings < Settingslogic
      CONFIGURATION = 'cloudkeeper-one.yml'.freeze

      # three possible configuration file locations in order by preference
      # if configuration file is found rest of the locations are ignored
      source "#{ENV['HOME']}/.cloudkeeper-one/#{CONFIGURATION}"\
      if File.exist?("#{ENV['HOME']}/.cloudkeeper-one/#{CONFIGURATION}")

      source "/etc/cloudkeeper-one/#{CONFIGURATION}"\
      if File.exist?("/etc/cloudkeeper-one/#{CONFIGURATION}")

      source "#{File.dirname(__FILE__)}/../../../config/#{CONFIGURATION}"

      namespace 'cloudkeeper-one'
    end
  end
end
