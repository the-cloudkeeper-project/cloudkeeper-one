require 'spec_helper'

describe Cloudkeeper::One::Opennebula::DatastoreHandler do
  subject(:handler) { described_class.new }

  before do
    Cloudkeeper::One::Settings[:'opennebula-secret'] = 'oneadmin:opennebula'
    Cloudkeeper::One::Settings[:'opennebula-endpoint'] = 'http://localhost:2633/RPC2'
  end

  describe '#new' do
    it 'creates an instance of Handler' do
      is_expected.to be_instance_of described_class
    end

    it 'initialize pool as DatastorePool' do
      expect(handler.pool).to be_instance_of OpenNebula::DatastorePool
    end
  end

  describe '.find_by_names', :vcr do
    context 'with all nonexistent names' do
      it 'returns an empty array' do
        expect(handler.find_by_names(%w(huey dewey louie))).to be_empty
      end
    end

    context 'with some valid and some invalid names' do
      it 'returns array of datastores with valid names' do
        datastores = handler.find_by_names %w(huey dewey system default)
        expect(datastores.count).to eq(2)
        expect(datastores.first.name).to eq('system')
        expect(datastores.last.name).to eq('default')
      end
    end

    context 'with all valid names' do
      it 'returns an array of datastores with valid names' do
        datastores = handler.find_by_names %w(files system default)
        expect(datastores.count).to eq(3)
        expect(datastores[0].name).to eq('files')
        expect(datastores[1].name).to eq('system')
        expect(datastores[2].name).to eq('default')
      end
    end
  end
end
