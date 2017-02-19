require 'spec_helper'

describe Cloudkeeper::One::Opennebula::ImageHandler do
  subject(:handler) { described_class.new }

  before do
    Cloudkeeper::One::Settings[:'opennebula-secret'] = 'oneadmin:opennebula'
    Cloudkeeper::One::Settings[:'opennebula-endpoint'] = 'http://localhost:2633/RPC2'
    Cloudkeeper::One::Settings[:identifier] = 'cloudkeeper-spec'
    Cloudkeeper::One::Settings[:'opennebula-api-call-timeout'] = 10
  end

  describe '#new' do
    it 'creates an instance of Handler' do
      is_expected.to be_instance_of described_class
    end

    it 'initialize pool as ImagePool' do
      expect(handler.pool).to be_instance_of OpenNebula::ImagePool
    end
  end

  describe '.expired', :vcr do
    context 'with users option set' do
      before do
        Cloudkeeper::One::Settings[:'opennebula-users'] = %w(user kile)
      end

      it 'returns list of all exprired images, with specified identifier and owned by one of the specified users' do
        images = handler.expired
        expect(images.count).to eq(2)
        expect(images.first.name).to eq('ttylinux05')
        expect(images.last.name).to eq('ttylinux06')
      end
    end

    context 'without users option set' do
      before do
        Cloudkeeper::One::Settings[:'opennebula-users'] = nil
      end

      it 'returns list of all expired images with specified identifier' do
        expect(handler.expired.count).to eq(3)
      end
    end
  end

  describe '.delete' do
    context 'with nil image' do
      it 'raises ArgumentError' do
        expect { handler.delete nil }.to raise_error(Cloudkeeper::One::Errors::ArgumentError)
      end
    end

    context 'with image', :vcr do
      it 'deletes the image' do
        image = handler.find_by_id 4
        handler.delete image
        expect(handler.find_by_id(4)).to be_nil
      end
    end

    context 'with used image', :vcr do
      it 'won\'t delete used image' do
        image = handler.find_by_id 5
        handler.delete image
        expect(handler.find_by_id(5)).not_to be_nil
      end
    end

    context 'image is not deleted within a timeout', :vcr do
      it 'raises ApiCallTimeoutError' do
        image = handler.find_by_id 5
        expect { handler.delete image }.to raise_error(Cloudkeeper::One::Errors::Opennebula::ApiCallTimeoutError)
      end
    end
  end

  describe '.disable' do
    context 'with nil image' do
      it 'raises ArgumentError' do
        expect { handler.disable nil }.to raise_error(Cloudkeeper::One::Errors::ArgumentError)
      end
    end

    context 'with already disabled image', :vcr do
      it 'won\'t disabe already disabled image' do
        image = handler.find_by_id 5
        handler.disable image
        expect(handler.disabled?(image)).to be_truthy
      end
    end

    context 'with image which is not free', :vcr do
      it 'won\'t disable image which is not free' do
        image = handler.find_by_id 5
        handler.disable image
        expect(handler.disabled?(image)).to be_falsy
      end
    end

    context 'with free image', :vcr do
      it 'disables image' do
        image = handler.find_by_id 5
        handler.disable image
        expect(handler.disabled?(image)).to be_truthy
      end
    end

    context 'image is not disabled within a timeout', :vcr do
      it 'raises ApiCallTimeoutError' do
        image = handler.find_by_id 5
        expect { handler.disable image }.to raise_error(Cloudkeeper::One::Errors::Opennebula::ApiCallTimeoutError)
      end
    end
  end

  describe '.expire' do
    context 'with nil image' do
      it 'raises ArgumentError' do
        expect { handler.expire nil }.to raise_error(Cloudkeeper::One::Errors::ArgumentError)
      end
    end

    context 'with already expired image', :vcr do
      it 'won\'t expire already expired image' do
        image = handler.find_by_id 6
        handler.expire image
        expect(handler.expired?(image)).to be_truthy
      end
    end

    context 'with image', :vcr do
      it 'expires image' do
        image = handler.find_by_id 7
        handler.expire image
        expect(handler.expired?(image)).to be_truthy
      end
    end
  end

  describe '.register', :vcr do
    let(:image_template) { "NAME = \"cloudkeeper-spec-image\"\nPATH = \"/var/tmp/file.img\"" }
    let(:datastore) { Cloudkeeper::One::Opennebula::DatastoreHandler.new.find_by_id 1 }

    context 'with correct template' do
      it 'registers new image in OpenNebula' do
        expect(handler.register(image_template, datastore)).not_to be_nil
      end
    end

    context 'image is not ready within a timeout' do
      it 'raises ApiCallTimeoutError' do
        expect { handler.register image_template, datastore }.to raise_error(Cloudkeeper::One::Errors::Opennebula::ApiCallTimeoutError)
      end
    end
  end

  describe 'expired?', :vcr do
    context 'with expired image' do
      it 'returns true' do
        image = handler.find_by_id 7
        expect(handler.expired?(image)).to be_truthy
      end
    end

    context 'with not expired image' do
      it 'returns false' do
        image = handler.find_by_id 5
        expect(handler.expired?(image)).to be_falsy
      end
    end
  end

  describe 'disabled?', :vcr do
    context 'with disabled image' do
      it 'returns true' do
        image = handler.find_by_id 7
        expect(handler.disabled?(image)).to be_truthy
      end
    end

    context 'with enabled image' do
      it 'returns false' do
        image = handler.find_by_id 5
        expect(handler.disabled?(image)).to be_falsy
      end
    end
  end

  describe 'ready?', :vcr do
    context 'with ready image' do
      it 'returns true' do
        image = handler.find_by_id 5
        expect(handler.ready?(image)).to be_truthy
      end
    end

    context 'with not ready image' do
      it 'returns false' do
        image = handler.find_by_id 7
        expect(handler.ready?(image)).to be_falsy
      end
    end
  end

  describe 'used?', :vcr do
    context 'with used image' do
      it 'returns true' do
        image = handler.find_by_id 3
        expect(handler.used?(image)).to be_truthy
      end
    end

    context 'with unused image' do
      it 'returns false' do
        image = handler.find_by_id 6
        expect(handler.used?(image)).to be_falsy
      end
    end
  end

  describe 'free?', :vcr do
    context 'with free image' do
      it 'returns true' do
        image = handler.find_by_id 5
        expect(handler.free?(image)).to be_truthy
      end
    end

    context 'with not free image' do
      it 'returns false' do
        image = handler.find_by_id 7
        expect(handler.free?(image)).to be_falsy
      end
    end
  end
end