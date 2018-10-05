require 'spec_helper'
require 'tmpdir'
require 'fileutils'

describe Cloudkeeper::One::ApplianceActions::Registration do
  subject(:registration) do
    class RegistrationMock
      include Cloudkeeper::One::ApplianceActions::Registration
      attr_accessor :image_handler, :template_handler, :datastore_handler

      def initialize
        @image_handler = Cloudkeeper::One::Opennebula::ImageHandler.new
        @template_handler = Cloudkeeper::One::Opennebula::TemplateHandler.new
        @datastore_handler = Cloudkeeper::One::Opennebula::DatastoreHandler.new
      end
    end

    RegistrationMock.new
  end

  before do
    Cloudkeeper::One::Settings[:'opennebula-secret'] = 'oneadmin:opennebula'
    Cloudkeeper::One::Settings[:'opennebula-endpoint'] = 'http://localhost:2633/RPC2'
    Cloudkeeper::One::Settings[:identifier] = 'cloudkeeper-spec'
    Cloudkeeper::One::Settings[:'opennebula-users'] = nil
    Cloudkeeper::One::Settings[:'opennebula-api-call-timeout'] = 10
    Cloudkeeper::One::Settings[:'appliances-permissions'] = '646'
    Cloudkeeper::One::Settings[:'appliances-template-dir'] = File.join(MOCK_DIR, 'templates')
    Cloudkeeper::One::Settings[:'opennebula-datastores'] = ['rspec-datastore']
  end

  describe '.register_or_update_appliance' do
    context 'with missing appliance' do
      it 'raise ArgumentError' do
        expect { registration.register_or_update_appliance nil }.to raise_error(Cloudkeeper::One::Errors::ArgumentError)
      end
    end

    context 'with all well and good', :vcr do
      let(:image) do
        Image.new '/tmp/cloudkeeper-spec-register-image/image.ext', 'cloudkeeper-spec', 'cloudkeeper-spec', :LOCAL, 'raw', '', '123',
                  '1b3a14fe8134'
      end
      let(:appliance) do
        Appliance.new 'qwerty123', 'Spec!', '', '', '', '', '', '', '', '', 'rspec-group', '', '', image, '', '123',
                      'b1ea3153bc15'
      end
      let(:image_handler) { Cloudkeeper::One::Opennebula::ImageHandler.new }
      let(:template_handler) { Cloudkeeper::One::Opennebula::TemplateHandler.new }

      it 'registers or updates appliance' do
        registration.register_or_update_appliance appliance
        expect(image_handler.find_by_name('qwerty123@rspec-datastore')).not_to be_nil
        expect(template_handler.find_by_name('qwerty123@rspec-datastore')).not_to be_nil
      end
    end
  end

  describe '.register_image' do
    let(:image_handler) { Cloudkeeper::One::Opennebula::ImageHandler.new }
    let(:datastore_handler) { Cloudkeeper::One::Opennebula::DatastoreHandler.new }
    let(:datastore) { datastore_handler.find_by_id 100 }

    context 'with no appliance' do
      let(:group) { instance_double(OpenNebula::Group) }
      let(:datastore) { instance_double(OpenNebula::Datastore) }

      it 'raise ArgumentError' do
        expect { registration.send(:register_image, nil, datastore) }.to raise_error(Cloudkeeper::One::Errors::ArgumentError)
      end
    end

    context 'with no image' do
      let(:datastore) { instance_double(OpenNebula::Datastore) }
      let(:appliance) { Struct.new(:image).new nil }

      it 'raise ArgumentError' do
        expect { registration.send(:register_image, nil, datastore) }.to raise_error(Cloudkeeper::One::Errors::ArgumentError)
      end
    end

    context 'with remote image', :vcr do
      let(:image) do
        Image.new 'http://localhost:9292/image.ext', 'cloudkeeper-spec', 'cloudkeeper-spec', :REMOTE, 'raw', '', '123abc',
                  '1b3a14fe8134'
      end
      let(:appliance) { Appliance.new 'qwerty123', 'Spec!', '', '', '', '', '', '', '', '', 'DA', '', '', image, '', '123', 'ab12078' }

      before do
        dir = File.join('/', 'tmp', 'cloudkeeper-spec-register-image')
        Dir.mkdir dir
        Cloudkeeper::One::Settings[:'appliances-tmp-dir'] = dir
      end

      after do
        FileUtils.remove_entry Cloudkeeper::One::Settings[:'appliances-tmp-dir']
      end

      it 'downloads and registers image in OpenNebula' do
        registration.send(:register_image, appliance, datastore)
        expect(image_handler.find_by_name('qwerty123@spec')).not_to be_nil
      end
    end

    context 'with local image', :vcr do
      let(:image) do
        Image.new '/tmp/cloudkeeper-spec-register-image/image.ext', 'cloudkeeper-spec', 'cloudkeeper-spec', :LOCAL, 'raw', '', '123',
                  '1b3a14fe8134'
      end
      let(:appliance) { Appliance.new 'qwerty123', 'Spec!', '', '', '', '', '', '', '', '', 'DA', '', '', image, '', '123', 'ab12078' }

      it 'registers image in OpenNebula' do
        registration.send(:register_image, appliance, datastore)
        expect(image_handler.find_by_name('qwerty123@spec')).not_to be_nil
      end
    end
  end

  describe '.register_template' do
    let(:template_handler) { Cloudkeeper::One::Opennebula::TemplateHandler.new }
    let(:group) { group_handler.find_by_id 100 }
    let(:image_id) { 32 }
    let(:name) { 'qwerty123@spec' }
    let(:appliance) { Appliance.new 'qwerty123', 'Spec!', '', '', '', '', '', '', '', '', 'DA', '', '', nil, '', '123', 'ab12078e' }

    context 'with no appliance' do
      let(:appliance) { Struct.new(:image).new nil }

      it 'raises ArgumentError' do
        expect { registration.send(:register_template, nil, image_id, name) }.to \
          raise_error(Cloudkeeper::One::Errors::ArgumentError)
      end
    end

    context 'with appliance', :vcr do
      it 'registers template in OpenNebula' do
        registration.send(:register_template, appliance, image_id, name)
        expect(template_handler.find_by_name('qwerty123@spec')).not_to be_nil
      end
    end
  end

  describe '.register_or_update_template', :vcr do
    let(:template_handler) { Cloudkeeper::One::Opennebula::TemplateHandler.new }
    let(:group) { group_handler.find_by_id 100 }
    let(:name) { 'qwerty123@spec' }

    context 'with appliance with alrerady existing template' do
      let(:image) { Struct.new(:id, :name).new 123, name }
      let(:appliance) { Appliance.new 'qwerty123', 'Spec!', '', '', '', '', '', '', '', '', 'XYZ', '', '', nil, '', '123', 'ab12078e' }

      it 'updates template' do
        expect(template_handler.find_by_name(name)).not_to be_nil
        registration.send(:register_or_update_template, appliance, image)
        expect((template_handler.find_by_name name)['TEMPLATE/CLOUDKEEPER_APPLIANCE_VO']).to eq('XYZ')
      end
    end

    context 'with appliance without a template' do
      let(:image) { Struct.new(:id, :name).new 123, name }
      let(:appliance) { Appliance.new 'qwerty123', 'Spec!', '', '', '', '', '', '', '', '', 'DA', '', '', nil, '', '123', 'ab12078e' }

      it 'registers template' do
        registration.send(:register_or_update_template, appliance, image)
        expect(template_handler.find_by_name(name)).not_to be_nil
      end
    end
  end
end
