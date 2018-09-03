require 'simplecov'
require 'yell'
require 'rspec/collection_matchers'
require 'webmock/rspec'
require 'vcr'
require 'json'

SimpleCov.start do
  add_filter '/vendor'
  add_filter '/spec'
end

require 'cloudkeeper_grpc'
require 'cloudkeeper/one'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

MOCK_DIR = File.join(File.dirname(__FILE__), 'mock')

Image = Struct.new(:location, :username, :password, :mode, :format, :uri, :checksum, :digest)
Appliance = Struct.new(:identifier, :title, :description, :mpuri, :group, :ram, :core, :version, :architecture, :operating_system, :vo,
                       :expiration_date, :image_list_identifier, :image, :base_mpuri, :appid, :digest)

WebMock.disable_net_connect!(allow_localhost: true)

VCR.configure do |config|
  config.cassette_library_dir = File.join(MOCK_DIR, 'cassettes')
  config.hook_into :webmock
  config.configure_rspec_metadata!
end

RSpec.configure do |config|
  config.color = true
  config.tty = true
  config.order = 'random'
end

Yell.new :file, '/dev/null', name: Object, level: 'error', format: Yell::DefaultFormat
# Yell.new :stdout, :name => Object, :level => 'debug', :format => Yell::DefaultFormat
Object.send :include, Yell::Loggable
