require 'spec_helper'

describe Cloudkeeper::One::Opennebula::Helper do
  subject(:helper) { Object.new.extend described_class }

  let(:endpoint) { 'http://localhost:2633/RPC2' }
  let(:secret) { 'user:opennebula' }
  let(:client) { OpenNebula::Client.new secret, endpoint }

  describe '.handle_opennebula_error' do
    context 'with wrong authentication', :vcr do
      let(:secret) { 'user:password' }

      it 'raises AuthenticationError' do
        image_pool = OpenNebula::ImagePool.new client
        expect { helper.handle_opennebula_error { image_pool.info! } }.to \
          raise_error(Cloudkeeper::One::Errors::Opennebula::AuthenticationError)
      end
    end

    context 'with wrong access rights', :vcr do
      it 'raises UserNotAuthorizedError' do
        image_alloc = OpenNebula::Image.build_xml(5)
        image = OpenNebula::Image.new image_alloc, client
        expect { helper.handle_opennebula_error { image.info! } }.to \
          raise_error(Cloudkeeper::One::Errors::Opennebula::UserNotAuthorizedError)
      end
    end

    context 'with nonexistent resource', :vcr do
      it 'raises ResourceNotFoundError' do
        image_alloc = OpenNebula::Image.build_xml(42)
        image = OpenNebula::Image.new image_alloc, client
        expect { helper.handle_opennebula_error { image.info! } }.to \
          raise_error(Cloudkeeper::One::Errors::Opennebula::ResourceNotFoundError)
      end
    end

    context 'with action on resource with wrong state', :vcr do
      it 'raises ResourceStateError' do
        image_alloc = OpenNebula::Image.build_xml(0)
        image = OpenNebula::Image.new image_alloc, client
        expect { helper.handle_opennebula_error { image.delete } }.to \
          raise_error(Cloudkeeper::One::Errors::Opennebula::ResourceStateError)
      end
    end
  end
end
