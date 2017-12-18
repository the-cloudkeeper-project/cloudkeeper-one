require 'spec_helper'

describe Cloudkeeper::One::ApplianceActions::Utils::TemplatePreparation do
  subject(:template_preparation) { Object.new.extend described_class }

  describe '.prepare_template' do
    let(:template_file) { 'spec.erb' }
    let(:appliance) do
      Struct.new(:identifier, :title, :description, :mpuri, :group, :ram, :core, :version, :architecture,
                 :operating_system, :vo, :expiration_date, :image_list_identifier, :attributes)
    end
    let(:data) do
      {
        message: 'It\'s alive!',
        appliance: appliance.new('qwerty123', 'Spec!', '', '', '', '', '', '', '', '', 'DA', '', '', answer: 42)
      }
    end

    before do
      Cloudkeeper::One::Settings[:'appliances-template-dir'] = File.join(MOCK_DIR, 'templates')
      Cloudkeeper::One::Settings[:identifier] = 'cloudkeeper-spec'
    end

    context 'without template file' do
      let(:template_file) { 'nospec.erb' }

      it 'raises ArgumentError' do
        expect { template_preparation.prepare_template(template_file, data) }.to raise_error(Cloudkeeper::One::Errors::ArgumentError)
      end
    end

    context 'with template file' do
      it 'returns data rendered as specified in template' do
        expect(template_preparation.prepare_template('spec.erb', data)).to \
          eq(File.read(File.join(MOCK_DIR, 'templates', 'spec.rendered')))
      end
    end
  end
end
