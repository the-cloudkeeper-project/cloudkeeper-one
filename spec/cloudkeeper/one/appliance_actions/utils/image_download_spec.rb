require 'spec_helper'
require 'tmpdir'
require 'fileutils'

describe Cloudkeeper::One::ApplianceActions::Utils::ImageDownload do
  subject(:image_download) { Object.new.extend described_class }

  before do
    Cloudkeeper::One::Settings[:'appliances-tmp-dir'] = Dir.mktmpdir('cloudkeeper-one-spec')
    Cloudkeeper::One::Settings[:'opennebula-allow-remote-source'] = false
  end

  after do
    FileUtils.remove_entry Cloudkeeper::One::Settings[:'appliances-tmp-dir']
  end

  describe '.generate_filename' do
    it 'generates random filenames in specified appliance directory' do
      path1 = image_download.send(:generate_filename)
      path2 = image_download.send(:generate_filename)
      path3 = image_download.send(:generate_filename)

      expect(path1).not_to eq(path2)
      expect(path1).not_to eq(path2)
      expect(path2).not_to eq(path3)

      expect(path1).to be_start_with(Cloudkeeper::One::Settings[:'appliances-tmp-dir'])
      expect(path2).to be_start_with(Cloudkeeper::One::Settings[:'appliances-tmp-dir'])
      expect(path3).to be_start_with(Cloudkeeper::One::Settings[:'appliances-tmp-dir'])
    end
  end

  describe '.retrieve_image', :vcr do
    let(:username) { 'cloudkeeper-spec' }
    let(:password) { 'cloudkeeper-spec' }
    let(:file) { File.join(Cloudkeeper::One::Settings[:'appliances-tmp-dir'], 'file') }
    let(:url) { URI.parse('http://localhost:9292/image.ext') }

    context 'with invalid uri' do
      let(:url) { URI.parse('http://localhost:9292/nomage.ext') }

      it 'raises NetworkConnectionError' do
        expect { image_download.send(:retrieve_image, url, username, password, file) }.to \
          raise_error(Cloudkeeper::One::Errors::NetworkConnectionError)
      end
    end

    context 'with invalid credentials' do
      let(:username) { 'cloudkeeper' }
      let(:password) { 'cloudkeeper' }

      it 'raises NetworkConnectionError' do
        expect { image_download.send(:retrieve_image, url, username, password, file) }.to \
          raise_error(Cloudkeeper::One::Errors::NetworkConnectionError)
      end
    end

    context 'with all parameters valid' do
      it 'downloads file' do
        image_download.send(:retrieve_image, url, username, password, file)
        expect(Digest::MD5.file(file).hexdigest).to eq('fac38ff3ef782be59900c1919d901063')
      end
    end
  end

  describe '.generate_url' do
    let(:username) { 'username' }
    let(:password) { 'password' }
    let(:uri) { 'http://localhost:9292/image.ext' }

    it 'returns URL with correct authentication information' do
      expect(image_download.send(:generate_url, uri, username, password)).to eq('http://username:password@localhost:9292/image.ext')
    end
  end

  describe '.download_image' do
    let(:username) { 'cloudkeeper-spec' }
    let(:password) { 'cloudkeeper-spec' }
    let(:url) { 'http://localhost:9292/image.ext' }

    context 'with invalid uri' do
      it 'raises NetworkConnectionError' do
        expect { image_download.download_image nil, username, password }.to \
          raise_error(Cloudkeeper::One::Errors::NetworkConnectionError)
      end
    end

    context 'with valid uri', :vcr do
      it 'downloads image to file with generated name' do
        filename = image_download.download_image url, username, password
        expect(Digest::MD5.file(filename).hexdigest).to eq('fac38ff3ef782be59900c1919d901063')
        expect(filename).to be_start_with(Cloudkeeper::One::Settings[:'appliances-tmp-dir'])
      end
    end

    context 'with allowed remote sources' do
      before do
        Cloudkeeper::One::Settings[:'opennebula-allow-remote-source'] = true
      end

      let(:username) { 'username' }
      let(:password) { 'password' }
      let(:uri) { 'http://localhost:9292/image.ext' }

      it 'returns remote URL' do
        expect(image_download.download_image(url, username, password)).to eq('http://username:password@localhost:9292/image.ext')
      end
    end
  end
end
