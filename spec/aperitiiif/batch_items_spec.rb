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
  end

  describe '.items_from_assets' do
    it 'returns an array of items' do
      expect(@batch.items_from_assets.first).to be_an(Aperitiiif::Item)
    end
  end
end
