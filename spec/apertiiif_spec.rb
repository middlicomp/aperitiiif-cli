# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Apertiiif do
  describe '.VERSION' do
    it 'returns version number string' do
      expect(Apertiiif::VERSION).to be_a(String)
    end
  end
  describe '.ALLOWED_SRC_FORMATS' do
    it 'returns array of format strings' do
      expect(Apertiiif::ALLOWED_SRC_FORMATS.first).to be_a(String)
    end
  end
end
