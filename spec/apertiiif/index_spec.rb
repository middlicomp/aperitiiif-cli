# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Apertiiif::Index do
  before(:all) do
    @batch = Apertiiif::Batch.new
    @batch.load_config_file 'spec/fixtures/config.yml'
    @index = Apertiiif::Index.new(@batch)
  end

  describe '.new' do
    it 'returns an index' do
      expect(Apertiiif::Index.new(@batch)).to be_an(Apertiiif::Index)
    end
  end

  describe '.path' do
  end

  describe '.write' do
  end

  describe '.to_json' do
    it 'returns the batch items represented as a JSON string' do
      expect(@index.to_json).to be_a(String)
    end
  end

  describe '.to_html' do
    it 'returns the batch items represented as an HTMl string' do
      expect(@index.to_html).to be_a(String)
    end
  end
end
