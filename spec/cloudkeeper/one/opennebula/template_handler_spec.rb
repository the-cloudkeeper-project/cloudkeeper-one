require 'spec_helper'

describe Cloudkeeper::One::Opennebula::TemplateHandler do
  subject(:handler) { described_class.new }

  before do
    Cloudkeeper::One::Settings[:'opennebula-secret'] = 'oneadmin:opennebula'
    Cloudkeeper::One::Settings[:'opennebula-endpoint'] = 'http://localhost:2633/RPC2'
    Cloudkeeper::One::Settings[:'appliances-permissions'] = '646'
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
    let(:group) { Cloudkeeper::One::Opennebula::GroupHandler.new.find_by_id 100 }

    it 'registers a new OpenNebula template' do
      template = handler.register(template_template, group)
      expect(template).not_to be_nil
      expect(template.gid).to eq(100)
      expect(template['PERMISSIONS/OWNER_U']).to eq('1')
      expect(template['PERMISSIONS/OWNER_M']).to eq('1')
      expect(template['PERMISSIONS/OWNER_A']).to eq('0')
      expect(template['PERMISSIONS/GROUP_U']).to eq('1')
      expect(template['PERMISSIONS/GROUP_M']).to eq('0')
      expect(template['PERMISSIONS/GROUP_A']).to eq('0')
      expect(template['PERMISSIONS/OTHER_U']).to eq('1')
      expect(template['PERMISSIONS/OTHER_M']).to eq('1')
      expect(template['PERMISSIONS/OTHER_A']).to eq('0')
    end
  end
end
