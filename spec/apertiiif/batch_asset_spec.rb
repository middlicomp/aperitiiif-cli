# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Apertiiif::Assets do
  before(:all) do
    @batch = Apertiiif::Batch.new
    @batch.load_config_file 'spec/fixtures/config.yml'
  end

  describe '.assets' do
    it 'returns array of assets' do
      expect(@batch.assets.first).to be_an(Apertiiif::Asset)
    end
  end

  describe '.child_assets' do
    context 'when given path to a directory of files' do
      it 'returns array of file paths in the directory' do
        @path = 'spec/fixtures/src/data/valid/dir'
        expect(@batch.child_assets(@path).count).to eq 2
      end
    end
    context 'when given path to a single file' do
      it 'returns array with that file path as only value' do
        @path = 'spec/fixtures/src/data/valid/valid.jpeg'
        expect(@batch.child_assets(@path).count).to eq 1
      end
    end
  end

  describe '.map_to_assets' do
    it 'returns array of assets' do
      expect(@batch.map_to_assets.first).to be_an(Apertiiif::Asset)
    end
  end

  describe '.asset_map' do
    it 'returns a hash map of parent items and their child assets' do
      expect(@batch.asset_map).to be_a(Hash)
    end
  end
end
