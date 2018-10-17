require 'spec_helper'

describe Cloudkeeper::One::Opennebula::DatastoreHandler do
  subject(:handler) { described_class.new }

  before do
    Cloudkeeper::One::Settings[:'opennebula-secret'] = 'oneadmin:opennebula'
    Cloudkeeper::One::Settings[:'opennebula-endpoint'] = 'http://localhost:2633/RPC2'
  end

  describe '#new' do
    it 'creates an instance of Handler' do
      expect(handler).to be_instance_of described_class
    end

    it 'initialize pool as DatastorePool' do
      expect(handler.pool).to be_instance_of OpenNebula::DatastorePool
    end
  end
end
