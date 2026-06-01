# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Aperitiiif::Assets do
  before(:all) do
    @batch = Aperitiiif::Batch.new
    @batch.load_config_file 'spec/fixtures/config.yml'
  end

  describe '.assets' do
    it 'returns array of assets' do
      expect(@batch.assets.first).to be_an(Aperitiiif::Asset)
    end
  end

  describe '.item_paths' do
    it 'returns top-level source paths for items' do
      expect(@batch.item_paths).to all(be_a(String))
      expect(@batch.item_paths).not_to be_empty
    end
  end

  describe '.item_asset_paths' do
    it 'returns the source file path for a single-file item' do
      path = 'spec/fixtures/src/data/valid/valid.jpeg'
      expect(@batch.item_asset_paths(path)).to eq [path]
    end

    it 'returns source file paths for a directory item' do
      path = 'spec/fixtures/src/data/valid/dir'
      expect(@batch.item_asset_paths(path).count).to eq 2
    end
  end

  describe '.asset_paths' do
    it 'returns a flat list of source asset paths' do
      expect(@batch.asset_paths).to all(be_a(String))
      expect(@batch.asset_paths).not_to be_empty
    end
  end
end
