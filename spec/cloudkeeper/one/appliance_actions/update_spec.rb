describe Cloudkeeper::One::ApplianceActions::Update do
  subject(:update) do
    class UpdateMock
      include Cloudkeeper::One::ApplianceActions::Update
      attr_accessor :image_handler, :template_handler

      def initialize
        @image_handler = Cloudkeeper::One::Opennebula::ImageHandler.new
        @template_handler = Cloudkeeper::One::Opennebula::TemplateHandler.new
      end
    end

    UpdateMock.new
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

  describe '.update_template', :vcr do
    let(:image) { Struct.new(:id).new 42 }
    let(:template_handler) { Cloudkeeper::One::Opennebula::TemplateHandler.new }
    let(:template) { template_handler.find_by_id 15 }
    let(:appliance) do
      Appliance.new 'qwerty123', 'Spec!', '', '', '', '', '', '42', '', '', 'rspec-group', '', '', { answer: 42 }, nil
    end

    it 'updates template' do
      update.update_template template, image, appliance
      expect(template_handler.find_by_id(15)['TEMPLATE/CLOUDKEEPER_APPLIANCE_VERSION']).to eq('42')
    end
  end

  describe '.update_image', :vcr do
    let(:image_handler) { Cloudkeeper::One::Opennebula::ImageHandler.new }
    let(:image) { image_handler.find_by_id 24 }
    let(:appliance) do
      Appliance.new 'qwerty123', 'Spec!', '', '', '', '', '', '42', '', '', 'rspec-group', '', '', { answer: 42 }, nil
    end

    it 'updates template' do
      update.update_image image, appliance
      expect(image_handler.find_by_id(24)['TEMPLATE/CLOUDKEEPER_APPLIANCE_VERSION']).to eq('42')
    end
  end

  describe '.update_appliance_metadata', :vcr do
    let(:appliance) do
      Appliance.new 'qwerty123', 'Spec!', '', '', '', '', '', '42', '', '', 'rspec-group', '', '', { answer: 42 }, nil
    end
    let(:image_handler) { Cloudkeeper::One::Opennebula::ImageHandler.new }
    let(:template_handler) { Cloudkeeper::One::Opennebula::TemplateHandler.new }

    it 'updates appliance' do
      update.update_appliance_metadata appliance
      expect(template_handler.find_by_id(15)['TEMPLATE/CLOUDKEEPER_APPLIANCE_VERSION']).to eq('42')
      expect(image_handler.find_by_id(24)['TEMPLATE/CLOUDKEEPER_APPLIANCE_VERSION']).to eq('42')
    end
  end
end
