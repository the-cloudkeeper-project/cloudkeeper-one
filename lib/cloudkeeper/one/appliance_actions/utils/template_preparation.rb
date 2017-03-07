require 'erb'
require 'tilt/erb'

module Cloudkeeper
  module One
    module ApplianceActions
      module Utils
        module TemplatePreparation
          def prepare_template(filename, data)
            template_file = File.join(Cloudkeeper::One::Settings[:'appliances-template-dir'], filename)
            raise Cloudkeeper::One::Errors::ArgumentError, "Missing file #{filename.inspect} in template directory" \
              unless File.exist?(template_file)

            templates = [template_file, File.join(File.dirname(__FILE__), 'templates', 'attributes.erb')]

            rendered = nil
            data[:image] ||= nil
            Tempfile.open 'cloudkeeper-template' do |tmp|
              templates.each { |template| tmp.write(File.read(template)) }
              tmp.flush

              template = Tilt::ERBTemplate.new tmp
              rendered = template.render Object.new, data
            end

            rendered
          end
        end
      end
    end
  end
end
