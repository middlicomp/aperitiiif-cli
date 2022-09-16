# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Aperitiiif::Batch do
  before(:all) do
    @batch = Aperitiiif::Batch.new
    @batch.load_config_file 'spec/fixtures/config.yml'
  end

  describe '.config' do
    context 'when a config is already loaded' do
      it 'returns the config' do
        expect(@batch.config).to be_an(Aperitiiif::Config)
        expect(@batch.config.label).to eq('Rijksmuseum Demo')
      end
    end
  end

  describe '.load_config_file' do
    before(:each) do
      @batch = Aperitiiif::Batch.new
    end
    context 'when given a file path' do
      context 'that does not exist' do
        it 'raises custom error' do
          expect do
            quiet_stdout { @batch.load_config_file('does-not-exist.yml') }
          end.to raise_error(Aperitiiif::Error)
        end
      end
      context 'that exists but is invalid yaml' do
        it 'raises custom error' do
          expect do
            quiet_stdout { @batch.load_config_file('spec/fixtures/bad-config.yml') }
          end.to raise_error(Aperitiiif::Error)
        end
      end
      context 'that exists and is valid' do
        it 'sets config instance var to new config object' do
          @batch.load_config_file 'spec/fixtures/config.yml'
          expect(@batch.config).to be_an(Aperitiiif::Config)
        end
      end
    end
  end

  describe '.load_config_hash' do
    context 'when given valid hash' do
      it 'sets config instance var to new config object' do
        @batch = Aperitiiif::Batch.new
        @batch.load_config_hash({ 'label' => 'my batch label' })
        expect(@batch.config).to be_an(Aperitiiif::Config)
      end
    end
  end

  describe '.reset' do
    context 'when given optional build dir' do
      it 'removes the build dir' do
        @dir = '.tmp-build-test'
        FileUtils.mkdir_p @dir
        quiet_stdout { @batch.reset @dir }
        expect(File.directory?(@dir)).to be(false)
      end
    end
    context 'when not given build dir' do
      it 'removes the default build dir' do
        @dir = @batch.config.build_dir
        FileUtils.mkdir_p @dir
        quiet_stdout { @batch.reset }
        expect(File.directory?(@dir)).to be(false)
      end
    end
  end

  describe '.write_target_assets' do
    context 'with source assets loaded' do
      it 'writes the target (converted TIF) assets to the build dir' do
        quiet_stdout { @batch.reset }
        quiet_stdout { @batch.write_target_assets }
        @written = @batch.assets.map(&:target_written?)
        expect(@written).to all be
      end
    end
  end

  describe '.write_presentation_json' do
    it 'writes item IIIF manifest files to presentation build dir' do
      quiet_stdout { @batch.reset }
      quiet_stdout { @batch.write_presentation_json }
      @written = @batch.items.map(&:manifest_written?)
      expect(@written).to all be
    end
  end

  describe '.seed' do
    it 'returns compacted hash' do
      expect(@batch.seed).to be_a(Hash)
    end
  end

  describe '.iiif_collection' do
    it 'returns a iiif collection' do
      expect(@batch.iiif_collection).to be_a(IIIF::Presentation::Collection)
    end
  end

  describe '.iiif_collection_file' do
    it 'returns string file path' do
      expect(@batch.iiif_collection_file).to end_with('.json')
    end
  end

  describe '.iiif_collection_url' do
    it 'returns valid url string' do
      expect(@batch.iiif_collection_url).to start_with('https')
      expect(@batch.iiif_collection_url).to end_with('.json')
    end
  end

  describe '.write_iiif_collection_json' do
    it 'writes one IIIF collection file to presentation build dir' do
      quiet_stdout { @batch.reset }
      quiet_stdout { @batch.write_iiif_collection_json }
      expect(@batch.iiif_collection_written?).to be
    end
  end
end
