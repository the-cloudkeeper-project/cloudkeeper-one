require 'spec_helper'

describe Cloudkeeper::One::Opennebula::ApplianceHandler do
  subject(:handler) { described_class.new }

  before do
    Cloudkeeper::One::Settings[:'opennebula-secret'] = 'oneadmin:opennebula'
    Cloudkeeper::One::Settings[:'opennebula-endpoint'] = 'http://localhost:2633/RPC2'
    Cloudkeeper::One::Settings[:identifier] = 'cloudkeeper-spec'
  end

  describe '#new' do
    it 'creates an instance of Handler' do
      is_expected.to be_instance_of described_class
    end

    it 'sets cloudkeeper instance identifier' do
      expect(handler.identifier).to eq('cloudkeeper-spec')
    end
  end

  describe '.find_by_appliance_id', :vcr do
    before do
      handler.pool = OpenNebula::ImagePool.new handler.client
    end

    context 'with existing appliance id' do
      context 'with users option set' do
        before do
          Cloudkeeper::One::Settings[:'opennebula-users'] = %w(user kile)
        end

        it 'returns all elements with specified appliance id, with specified identifier and owned by one of the users' do
          elements = handler.find_by_appliance_id '222'
          expect(elements.count).to eq(2)
          expect(elements.first.name).to eq('ttylinux03')
          expect(elements.last.name).to eq('ttylinux05')
        end
      end

      context 'without users options sets' do
        before do
          Cloudkeeper::One::Settings[:'opennebula-users'] = nil
        end

        it 'returns all elements with specified appliance id and with specified identifier' do
          elements = handler.find_by_appliance_id '222'
          expect(elements.count).to eq(2)
          expect(elements.first.name).to eq('ttylinux02')
          expect(elements.last.name).to eq('ttylinux03')
        end
      end
    end

    context 'with nonexisting appliance id' do
      it 'returns an empty array' do
        expect(handler.find_by_appliance_id('nonexisting-appliance-id')).to be_empty
      end
    end
  end

  describe '.find_by_image_list_id', :vcr do
    before do
      handler.pool = OpenNebula::ImagePool.new handler.client
    end

    context 'with existing image list id' do
      context 'with users option set' do
        before do
          Cloudkeeper::One::Settings[:'opennebula-users'] = %w(user kile)
        end

        it 'returns all elements with specified image list id, with specified identifier and owned by one of the users' do
          elements = handler.find_by_image_list_id '222'
          expect(elements.count).to eq(2)
          expect(elements.first.name).to eq('ttylinux03')
          expect(elements.last.name).to eq('ttylinux05')
        end
      end

      context 'without users options sets' do
        before do
          Cloudkeeper::One::Settings[:'opennebula-users'] = nil
        end

        it 'returns all elements with specified image list id and with specified identifier' do
          elements = handler.find_by_image_list_id '222'
          expect(elements.count).to eq(3)
          expect(elements.first.name).to eq('ttylinux03')
          expect(elements.last.name).to eq('ttylinux05')
        end
      end
    end

    context 'with nonexisting image list id' do
      it 'returns an empty array' do
        expect(handler.find_by_image_list_id('nonexisting-image-list-id')).to be_empty
      end
    end
  end

  describe '.delete' do
    before do
      Cloudkeeper::One::Settings[:'opennebula-api-call-timeout'] = 10
      handler.pool = OpenNebula::ImagePool.new handler.client
    end

    context 'with nil element' do
      it 'raises ArgumentError' do
        expect { handler.delete nil }.to raise_error(Cloudkeeper::One::Errors::ArgumentError)
      end
    end

    context 'with element', :vcr do
      it 'deletes the element' do
        element = handler.find_by_id 2
        handler.delete element
        expect(handler.find_by_id(2)).to be_nil
      end
    end

    context 'element is not deleted within a timeout', :vcr do
      it 'raises ApiCallTimeoutError' do
        element = handler.find_by_id 2
        expect { handler.delete element }.to raise_error(Cloudkeeper::One::Errors::Opennebula::ApiCallTimeoutError)
      end
    end
  end

  describe '.find', :vcr do
    before do
      handler.pool = OpenNebula::ImagePool.new handler.client
    end

    context 'with find method' do
      context 'with specified xpath' do
        it 'returns first element meeting the specified xpath with specified identifier' do
          expect(handler.send(:find, :find, 'TEMPLATE/SPEC_ATTRIBUTE' => 'test').id).to eq(6)
        end
      end

      context 'without specified xpath' do
        it 'returns first element with specified identifier' do
          expect(handler.send(:find, :find).id).to eq(5)
        end
      end
    end

    context 'with find_all method' do
      context 'with specified xpath' do
        it 'returns all elements meeting the specified xpath with specified identifier' do
          elements = handler.send(:find, :find_all, 'TEMPLATE/SPEC_ATTRIBUTE' => 'test')
          expect(elements.count).to eq(2)
          expect(elements.first.id).to eq(6)
          expect(elements.last.id).to eq(7)
        end
      end

      context 'without specified xpath' do
        it 'returns all elements with specified identifier' do
          expect(handler.send(:find, :find_all).count).to eq(3)
        end
      end
    end
  end

  describe '.chmod' do
    before do
      handler.pool = OpenNebula::ImagePool.new handler.client
    end

    context 'with nil element' do
      it 'raises ArgumentError' do
        expect { handler.chmod nil, '467' }.to raise_error(Cloudkeeper::One::Errors::ArgumentError)
      end
    end

    context 'with element', :vcr do
      it 'changes permissions on the element' do
        element = handler.find_by_id 8
        handler.chmod element, '467'
        expect(element['PERMISSIONS/OWNER_U']).to eq('1')
        expect(element['PERMISSIONS/OWNER_M']).to eq('0')
        expect(element['PERMISSIONS/OWNER_A']).to eq('0')
        expect(element['PERMISSIONS/GROUP_U']).to eq('1')
        expect(element['PERMISSIONS/GROUP_M']).to eq('1')
        expect(element['PERMISSIONS/GROUP_A']).to eq('0')
        expect(element['PERMISSIONS/OTHER_U']).to eq('1')
        expect(element['PERMISSIONS/OTHER_M']).to eq('1')
        expect(element['PERMISSIONS/OTHER_A']).to eq('1')
      end
    end
  end

  describe '.chgrp', :vcr do
    before do
      handler.pool = OpenNebula::ImagePool.new handler.client
    end

    let(:group) { Cloudkeeper::One::Opennebula::GroupHandler.new.find_by_id 100 }

    context 'with nil element' do
      it 'raises ArgumentError' do
        expect { handler.chgrp nil, group }.to raise_error(Cloudkeeper::One::Errors::ArgumentError)
      end
    end

    context 'with element with the same group' do
      it 'will keep the same group' do
        element = handler.find_by_id 5
        handler.chgrp element, group
        expect(element.gid).to eq(100)
      end
    end

    context 'with element with different group' do
      it 'changes element\'s group to specified group' do
        element = handler.find_by_id 6
        handler.chgrp element, group
        expect(element.gid).to eq(100)
      end
    end
  end

  describe '.update', :vcr do
    before do
      handler.pool = OpenNebula::ImagePool.new handler.client
    end

    let(:template) { 'NEW_ELEMENT = "lalala"' }
    let(:element) { handler.find_by_id 23 }

    context 'with nil element' do
      it 'raises ArgumentError' do
        expect { handler.update nil, template }.to raise_error(Cloudkeeper::One::Errors::ArgumentError)
      end
    end

    context 'with element' do
      it 'updates element\'s template' do
        handler.update element, template
        expect(element['TEMPLATE/NEW_ELEMENT']).to eq('lalala')
      end
    end
  end
end
