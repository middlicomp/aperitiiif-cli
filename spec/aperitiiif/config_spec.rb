# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Aperitiiif::Config do
  before(:context) do
    @seed   = { 'label' => 'my batch label' }
    @config = Aperitiiif::Config.new(@seed)
  end
  describe '.new' do
    context 'when given the minimum metadata (label)' do
      it 'creates a config object' do
        expect(@config).to be_an(Aperitiiif::Config)
      end
    end
    context 'when not given the minimum metadata (label)' do
      it 'creates a config object' do
        expect do
          quiet_stdout { Aperitiiif::Config.new }
        end.to raise_error(Aperitiiif::Error)
      end
    end
  end

  describe '.batch_namespace' do
    it 'deduces namespace from current directory' do
      @dir    = '/Users/fake/supernot_realATall/aperitiiif-batch_result'
      @result = @config.batch_namespace @dir
      expect(@result).to eq('result')
    end
  end

  describe '.presentation_build_dir' do
    it 'interpolates default build_dir' do
      expect(@config.presentation_build_dir).to eq('./build/presentation')
    end
  end

  describe '.image_build_dir' do
    it 'interpolates default build_dir' do
      expect(@config.image_build_dir).to eq('./build/image')
    end
  end

  describe '.html_build_dir' do
    it 'interpolates default build_dir' do
      expect(@config.html_build_dir).to eq('./build/html')
    end
  end

  describe '.records_file' do
    it 'defaults to empty string' do
      expect(@config.records_file).to be_a(String)
      expect(@config.records_file).to be_empty
    end
  end

  describe '.records_defaults' do
    it 'defaults to empty hash' do
      expect(@config.records_defaults).to be_a(Hash)
      expect(@config.records_defaults).to be_empty
    end
  end
end
