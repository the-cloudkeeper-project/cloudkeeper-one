require 'spec_helper'

describe Cloudkeeper::One::Opennebula::Handler do
  subject(:handler) { described_class.new }

  before do
    Cloudkeeper::One::Settings[:'opennebula-secret'] = 'oneadmin:opennebula'
    Cloudkeeper::One::Settings[:'opennebula-endpoint'] = 'http://localhost:2633/RPC2'
  end

  describe '#new' do
    it 'creates an instance of Handler' do
      is_expected.to be_instance_of described_class
    end

    it 'initialize OpenNebula client' do
      expect(handler.client).to be_instance_of OpenNebula::Client
    end
  end

  describe '.find_one', :vcr do
    before do
      handler.pool = OpenNebula::ImagePool.new handler.client
    end

    context 'without additional xpath' do
      it 'returns first element from the pool' do
        expect(handler.find_one.id).to eq(2)
      end
    end

    context 'with additional xpath' do
      it 'returns first element from the pool meeting specified xpath' do
        expect(handler.find_one('TEMPLATE/SPEC_ATTRIBUTE' => 'test').id).to eq(4)
      end
    end
  end

  describe '.find_all', :vcr do
    before do
      handler.pool = OpenNebula::ImagePool.new handler.client
    end

    context 'without additional xpath' do
      it 'returns all elements from the pool' do
        expect(handler.find_all.count).to eq(4)
      end
    end

    context 'with additional xpath' do
      it 'returns all elements from the pool meeting specified xpath' do
        elements = handler.find_all('TEMPLATE/SPEC_ATTRIBUTE' => 'test')
        expect(elements.count).to eq(2)
        expect(elements.first.id).to eq(3)
        expect(elements.last.id).to eq(4)
      end
    end
  end

  describe '.find_by_name', :vcr do
    before do
      handler.pool = OpenNebula::ImagePool.new handler.client
    end

    context 'if element with specified name exists' do
      it 'returns element with specified name from the pool' do
        expect(handler.find_by_name('ttylinux03').id).to eq(3)
      end
    end

    context 'if there is no element with specified name' do
      it 'returns nil' do
        expect(handler.find_by_name('nonexistingname')).to be_nil
      end
    end
  end

  describe '.find_by_id', :vcr do
    before do
      handler.pool = OpenNebula::ImagePool.new handler.client
    end

    context 'if element with specified id exists' do
      it 'returns element with specified id from the pool' do
        expect(handler.find_by_id(3).name).to eq('ttylinux03')
      end
    end

    context 'if there is no element with specified id' do
      it 'returns nil' do
        expect(handler.find_by_id(42)).to be_nil
      end
    end
  end

  describe '.exist?', :vcr do
    before do
      handler.pool = OpenNebula::ImagePool.new handler.client
    end

    context 'if element with specified id exists' do
      it 'returns true' do
        expect(handler.exist?(3)).to be_truthy
      end
    end

    context 'if there is no element with specified id' do
      it 'returns false' do
        expect(handler.exist?(42)).to be_falsy
      end
    end
  end

  describe '.find', :vcr do
    before do
      handler.pool = OpenNebula::ImagePool.new handler.client
    end

    context 'with find method' do
      context 'with specified xpath' do
        it 'returns first element meeting the specified xpath' do
          expect(handler.send(:find, :find, 'TEMPLATE/SPEC_ATTRIBUTE' => 'test').id).to eq(3)
        end
      end

      context 'without specified xpath' do
        it 'returns first element' do
          expect(handler.send(:find, :find).id).to eq(2)
        end
      end
    end

    context 'with find_all method' do
      context 'with specified xpath' do
        it 'returns all elements meeting the specified xpath' do
          elements = handler.send(:find, :find_all, 'TEMPLATE/SPEC_ATTRIBUTE' => 'test')
          expect(elements.count).to eq(2)
          expect(elements.first.id).to eq(3)
          expect(elements.last.id).to eq(4)
        end
      end

      context 'without specified xpath' do
        it 'returns all elements' do
          expect(handler.send(:find, :find_all).count).to eq(4)
        end
      end
    end
  end

  describe '.evaluate_xpaths' do
    let(:element) do
      {
        'NAME' => 'element',
        'ID' => 123
      }
    end

    context 'with no xpaths' do
      it 'returns true' do
        expect(handler.send(:evaluate_xpaths, element, {})).to be_truthy
      end
    end

    context 'with one truthy xpath' do
      it 'returns true' do
        expect(handler.send(:evaluate_xpaths, element, 'NAME' => 'element')).to be_truthy
      end
    end

    context 'with one falsy xpath' do
      it 'returns false' do
        expect(handler.send(:evaluate_xpaths, element, 'NAME' => 'tnemele')).to be_falsy
      end
    end

    context 'with one truthy and one falsy xpath' do
      it 'returns false' do
        expect(handler.send(:evaluate_xpaths, element, 'NAME' => 'element', 'ID' => 456)).to be_falsy
      end
    end

    context 'with array-like truthy xpath' do
      it 'returns true' do
        expect(handler.send(:evaluate_xpaths, element, 'NAME' => %w(alement blement clement element flement))).to be_truthy
      end
    end

    context 'with array-like falsy xpath' do
      it 'returns false' do
        expect(handler.send(:evaluate_xpaths, element, 'ID' => [111, 222, 333, 444])).to be_falsy
      end
    end
  end

  describe '.reload!' do
    context 'without a pool' do
      it 'raises MissingPoolError' do
        expect { handler.send(:reload!) }.to raise_error(Cloudkeeper::One::Errors::Opennebula::MissingPoolError)
      end
    end

    context 'on pool with info_all! method' do
      before do
        handler.pool = OpenNebula::ImagePool.new handler.client
        allow(handler.pool).to receive(:info_all!)
      end

      after do
        expect(handler.pool).to have_received(:info_all!)
      end

      it 'calls info_all! method on pool' do
        handler.send(:reload!)
      end
    end

    context 'on pool without info_all! method' do
      before do
        handler.pool = OpenNebula::DatastorePool.new handler.client
        allow(handler.pool).to receive(:info!)
      end

      after do
        expect(handler.pool).to have_received(:info!)
      end

      it 'calls info! method on pool' do
        handler.send(:reload!)
      end
    end
  end
end
