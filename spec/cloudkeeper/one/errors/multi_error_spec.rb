require 'spec_helper'

describe Cloudkeeper::One::Errors::MultiError do
  subject(:error) { described_class.new }

  describe '#new' do
    it 'creates an instance of MultiError' do
      expect(error).to be_instance_of described_class
    end

    it 'initializes errors attribute to an empty array' do
      expect(error.errors).to be_instance_of Array
      expect(error.errors).to be_empty
    end
  end

  describe '.<<' do
    it 'adds error to errors array' do
      error << :error
      expect(error.count).to eq 1
    end
  end

  describe '.message' do
    let(:message) { 'aaa|bbb|ccc' }

    it 'returns concatenated error messages of all stored errors' do
      error << StandardError.new('aaa')
      error << StandardError.new('bbb')
      error << StandardError.new('ccc')
      expect(error.message).to eq message
    end
  end

  describe '.count' do
    it 'returns number of stored errors' do
      error << StandardError.new('aaa')
      error << StandardError.new('bbb')
      expect(error.count).to eq 2
    end
  end
end
