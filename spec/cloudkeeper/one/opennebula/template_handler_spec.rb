require 'spec_helper'

describe Cloudkeeper::One::Opennebula::TemplateHandler do
  subject(:handler) { described_class.new }

  before do
    Cloudkeeper::One::Settings[:'opennebula-secret'] = 'oneadmin:opennebula'
    Cloudkeeper::One::Settings[:'opennebula-endpoint'] = 'http://localhost:2633/RPC2'
  end

  describe '#new' do
    it 'creates an instance of Handler' do
      is_expected.to be_instance_of described_class
    end

    it 'initialize pool as TemplatePool' do
      expect(handler.pool).to be_instance_of OpenNebula::TemplatePool
    end
  end

  describe '.register', :vcr do
    let(:template_template) { 'NAME = "cloudkeeper-spec-template"' }
    it 'registers a new OpenNebula template' do
      expect(handler.register(template_template)).not_to be_nil
    end
  end
end
