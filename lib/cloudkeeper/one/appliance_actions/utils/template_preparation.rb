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

            logger.debug "Populating template from #{template_file}"
            templates = [template_file, File.join(File.dirname(__FILE__), 'templates', 'attributes.erb')]

            data[:image] ||= nil
            rendered = render_templates templates, data
            logger.debug "Template:\n#{rendered}"
            rendered
          end

          def render_templates(templates, data)
            Tempfile.open 'cloudkeeper-template' do |tmp|
              templates.each { |template| tmp.write(File.read(template)) }
              tmp.flush

              template = Tilt::ERBTemplate.new tmp
              template.render Object.new, data
            end
          end
        end
      end
    end
  end
end
