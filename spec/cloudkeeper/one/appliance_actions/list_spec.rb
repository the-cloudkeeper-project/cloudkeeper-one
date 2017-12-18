require 'spec_helper'

describe Cloudkeeper::One::ApplianceActions::List do
  subject(:list) do
    class ListMock
      include Cloudkeeper::One::ApplianceActions::List
      attr_accessor :image_handler, :template_handler

      def initialize
        @image_handler = Cloudkeeper::One::Opennebula::ImageHandler.new
        @template_handler = Cloudkeeper::One::Opennebula::TemplateHandler.new
      end
    end

    ListMock.new
  end

  before do
    Cloudkeeper::One::Settings[:'opennebula-secret'] = 'oneadmin:opennebula'
    Cloudkeeper::One::Settings[:'opennebula-endpoint'] = 'http://localhost:2633/RPC2'
    Cloudkeeper::One::Settings[:identifier] = 'cloudkeeper-spec'
    Cloudkeeper::One::Settings[:'opennebula-users'] = nil
  end

  describe '.list_image_lists', :vcr do
    context 'with some templates missing image list identifier' do
      it 'skips templates without image list identifier ale returns rest of the found image list identifiers' do
        image_lists = list.list_image_lists
        expect(image_lists[0].image_list_identifier).to eq('111')
        expect(image_lists[1].image_list_identifier).to eq('222')
        expect(image_lists[2].image_list_identifier).to eq('333')
      end
    end

    context 'with all templates with image list identifiers' do
      it 'returns all found image list identifiers' do
        image_lists = list.list_image_lists
        expect(image_lists[0].image_list_identifier).to eq('111')
        expect(image_lists[1].image_list_identifier).to eq('222')
        expect(image_lists[2].image_list_identifier).to eq('333')
        expect(image_lists[3].image_list_identifier).to eq('444')
      end
    end
  end

  describe '.list_appliances', :vcr do
    context 'with image list identifier that has no appliances in OpenNebula' do
      it 'returns an empty array' do
        expect(list.list_appliances('nonexisting_image_list_id')).to be_empty
      end
    end

    context 'with image list identifier that has appliances in OpenNebula' do
      it 'returns array of proto appliances from specified image list' do
        appliances = list.list_appliances '1a2b3c'
        proto_appliance = appliances.first
        expect(proto_appliance.identifier).to eq('qwerty123')
        expect(proto_appliance.description).to eq('')
        expect(proto_appliance.mpuri).to eq('')
        expect(proto_appliance.title).to eq('Spec!')
        expect(proto_appliance.group).to eq('')
        expect(proto_appliance.ram).to eq(0)
        expect(proto_appliance.core).to eq(0)
        expect(proto_appliance.version).to eq('42')
        expect(proto_appliance.architecture).to eq('')
        expect(proto_appliance.operating_system).to eq('')
        expect(proto_appliance.vo).to eq('rspec-group')
        expect(proto_appliance.expiration_date).to eq(0)
        expect(proto_appliance.image_list_identifier).to eq('1a2b3c')
        expect(proto_appliance.attributes).to eq('answer' => '42')
        expect(proto_appliance.image).to be_nil
      end
    end
  end

  describe '.check_image_for_template!', :vcr do
    context 'with image coresponding to template' do
      let(:template) { Cloudkeeper::One::Opennebula::TemplateHandler.new.find_by_id 15 }

      it 'does not raise an exception' do
        expect { list.send(:check_image_for_template!, template) }.not_to raise_error
      end
    end

    context 'with no coresponding image' do
      let(:template) { Cloudkeeper::One::Opennebula::TemplateHandler.new.find_by_id 7 }

      it 'raises ListingError' do
        expect { list.send(:check_image_for_template!, template) }.to raise_error(Cloudkeeper::One::Errors::Actions::ListingError)
      end
    end
  end

  describe '.populate_proto_appliance', :vcr do
    let(:image) { Cloudkeeper::One::Opennebula::ImageHandler.new.find_by_id 24 }
    let(:template) { Cloudkeeper::One::Opennebula::TemplateHandler.new.find_by_id 15 }

    it 'populates proto appliance and image structures' do
      proto_appliance = list.send(:populate_proto_appliance, template)
      expect(proto_appliance.identifier).to eq('qwerty123')
      expect(proto_appliance.description).to eq('')
      expect(proto_appliance.mpuri).to eq('')
      expect(proto_appliance.title).to eq('Spec!')
      expect(proto_appliance.group).to eq('')
      expect(proto_appliance.ram).to eq(0)
      expect(proto_appliance.core).to eq(0)
      expect(proto_appliance.version).to eq('42')
      expect(proto_appliance.architecture).to eq('')
      expect(proto_appliance.operating_system).to eq('')
      expect(proto_appliance.vo).to eq('rspec-group')
      expect(proto_appliance.expiration_date).to eq(0)
      expect(proto_appliance.image_list_identifier).to eq('')
      expect(proto_appliance.attributes).to eq('answer' => '42')
      expect(proto_appliance.image).to be_nil
    end
  end
end
