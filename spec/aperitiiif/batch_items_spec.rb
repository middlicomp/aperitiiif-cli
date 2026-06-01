# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Aperitiiif::Items do
  before(:all) do
    @batch = Aperitiiif::Batch.new
    @batch.load_config_file 'spec/fixtures/config.yml'
  end

  describe '.items' do
    it 'returns an array of items' do
      expect(@batch.items.first).to be_an(Aperitiiif::Item)
    end

    it 'loads items from source paths and defers asset instantiation' do
      item = @batch.items.first
      expect(item.asset_paths).to all(be_a(String))
      expect(item.instance_variable_defined?(:@assets)).to be(false)
    end
  end

  describe '.items_from_paths' do
    it 'returns an array of items from source paths' do
      expect(@batch.items_from_paths.first).to be_an(Aperitiiif::Item)
    end
  end
end
