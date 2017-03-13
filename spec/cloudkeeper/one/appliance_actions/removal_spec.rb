require 'spec_helper'

describe Cloudkeeper::One::ApplianceActions::Removal do
  subject(:removal) do
    class RemovalMock
      include Cloudkeeper::One::ApplianceActions::Removal
      attr_accessor :image_handler, :template_handler

      def initialize
        @image_handler = Cloudkeeper::One::Opennebula::ImageHandler.new
        @template_handler = Cloudkeeper::One::Opennebula::TemplateHandler.new
      end
    end

    RemovalMock.new
  end

  before do
    Cloudkeeper::One::Settings[:'opennebula-secret'] = 'oneadmin:opennebula'
    Cloudkeeper::One::Settings[:'opennebula-endpoint'] = 'http://localhost:2633/RPC2'
    Cloudkeeper::One::Settings[:identifier] = 'cloudkeeper-spec'
    Cloudkeeper::One::Settings[:'opennebula-users'] = nil
  end

  describe '.remove_expired', :vcr do
    let(:image_handler) { Cloudkeeper::One::Opennebula::ImageHandler.new }

    context 'with expired images in OpenNebula' do
      it 'removes expired images from OpenNebula' do
        removal.remove_expired
        expect(image_handler.find_by_id(17)).to be_nil
        expect(image_handler.find_by_id(19)).to be_nil
        expect(image_handler.find_by_id(20)).to be_nil
      end
    end

    context 'without expired images in OpenNebula' do
      it 'doesn\'t remove any additional images from OpenNebula' do
        removal.remove_expired
        expect(image_handler.find_all.count).to eq(4)
      end
    end
  end

  describe '.remove_images', :vcr do
    let(:image_handler) { Cloudkeeper::One::Opennebula::ImageHandler.new }

    context 'with images with specified identifier in OpenNebula' do
      context 'which are used' do
        it 'expires images with specified identifier in OpenNebula' do
          removal.remove_images :find_by_appliance_id, 'qwerty123'
          image = image_handler.find_by_id 18
          expect(image_handler.expired?(image)).to be_truthy
          image = image_handler.find_by_id 21
          expect(image_handler.expired?(image)).to be_truthy
        end
      end

      context 'which are not used' do
        it 'removes images with specified identifier from OpenNebula' do
          removal.remove_images :find_by_appliance_id, 'qwerty123'
          expect(image_handler.find_by_id(18)).to be_nil
          expect(image_handler.find_by_id(21)).to be_nil
        end
      end
    end

    context 'without images with specified identifier in OpenNebula' do
      it 'doesn\'t remove any additional images from OpenNebula' do
        removal.remove_images :find_by_appliance_id, 'qwerty123'
        expect(image_handler.find_all.count).to eq(2)
      end
    end
  end

  describe '.remove_templates', :vcr do
    let(:template_handler) { Cloudkeeper::One::Opennebula::TemplateHandler.new }

    context 'with templates with specified identifier in OpenNebula' do
      it 'removes templates with specified identifier from OpenNebula' do
        removal.remove_templates :find_by_appliance_id, 'qwerty123'
        expect(template_handler.find_all.count).to eq(4)
      end
    end

    context 'without templates with specified identifier in OpenNebula' do
      it 'doesn\'t remove any additional templates from OpenNebula' do
        removal.remove_templates :find_by_appliance_id, 'qwerty123'
        expect(template_handler.find_all.count).to eq(4)
      end
    end
  end

  describe '.remove_appliance', :vcr do
    let(:image_handler) { Cloudkeeper::One::Opennebula::ImageHandler.new }
    let(:template_handler) { Cloudkeeper::One::Opennebula::TemplateHandler.new }

    context 'with images and templates with specified identifier in OpenNebula' do
      it 'removes both images and templates with this identifier from OpenNebula' do
        removal.remove_appliance 'qwerty123'
        expect(image_handler.find_all.count).to eq(0)
        expect(template_handler.find_all.count).to eq(2)
      end
    end

    context 'without images or templates with specified identifier in OpenNebula' do
      it 'doesn\'t remove any additional images or templates form OpenNebula' do
        removal.remove_appliance 'qwerty123'
        expect(image_handler.find_all.count).to eq(0)
        expect(template_handler.find_all.count).to eq(2)
      end
    end
  end

  describe '.remove_image_list', :vcr do
    let(:image_handler) { Cloudkeeper::One::Opennebula::ImageHandler.new }
    let(:template_handler) { Cloudkeeper::One::Opennebula::TemplateHandler.new }

    context 'with images and templates with specified image list identifier in OpenNebula' do
      it 'removes both images and templates with this image list identifier from OpenNebula' do
        removal.remove_image_list 'qwerty123'
        expect(image_handler.find_all.count).to eq(0)
        expect(template_handler.find_all.count).to eq(1)
      end
    end

    context 'without images or templates with specified image list identifier in OpenNebula' do
      it 'doesn\'t remove any additional images or templates form OpenNebula' do
        removal.remove_image_list 'qwerty123'
        expect(image_handler.find_all.count).to eq(0)
        expect(template_handler.find_all.count).to eq(1)
      end
    end
  end

  describe '.handle_iteration' do
    context 'with a block' do
      context 'with errors' do
        it 'iterates over all items and raises error at the end' do
          expect do
            removal.send(:handle_iteration, [5, 2, 1]) { |item| raise Cloudkeeper::One::Errors::ArgumentError if item == 5 }
          end.to raise_error(Cloudkeeper::One::Errors::ArgumentError)
        end
      end

      context 'withotu errors' do
        it 'iterates over all items' do
          expect do
            removal.send(:handle_iteration, [1, 2, 3]) { |item| raise Cloudkeeper::One::Errors::ArgumentError if item == 5 }
          end.not_to raise_error
        end
      end
    end

    context 'without a block' do
      it 'raises ArgumentError' do
        expect { removal.send(:handle_iteration, []) }.to raise_error(Cloudkeeper::One::Errors::ArgumentError)
      end
    end
  end
end
