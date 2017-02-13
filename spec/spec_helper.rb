require 'simplecov'
require 'yell'
require 'rspec/collection_matchers'
require 'vcr'
require 'json'

SimpleCov.start do
  add_filter '/vendor'
  add_filter '/spec'
end

Diffy::Diff.default_format = :color

require 'cloudkeeper_grpc'
require 'cloudkeeper/one'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

MOCK_DIR = File.join(File.dirname(__FILE__), 'mock')

RSpec.configure do |config|
  config.color = true
  config.tty = true
  config.order = 'random'
end

Yell.new :file, '/dev/null', name: Object, level: 'error', format: Yell::DefaultFormat
# Yell.new :stdout, :name => Object, :level => 'debug', :format => Yell::DefaultFormat
Object.send :include, Yell::Loggable
