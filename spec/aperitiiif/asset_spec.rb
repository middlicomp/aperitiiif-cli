# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Aperitiiif::Asset do
  before(:context) do
    @parent_id  = 'test'
    @source     = 'spec/fixtures/src/data/valid/valid.jpeg'
    @conf_opts  = {
      'label' => 'my batch label',
      'presentation_api_url' => 'https://example.com/presentation',
      'image_api_url' => 'https://example.com/presentation'
    }
    @config     = Aperitiiif::Config.new @conf_opts
    @asset      = Aperitiiif::Asset.new @parent_id, @source, @config
  end

  describe '.new' do
    context 'when not given requisite configuration'
    it 'raises custom errors' do
      @config = Aperitiiif::Config.new({ 'label' => 'my batch label' })
      expect do
        quiet_stdout { Aperitiiif::Asset.new(@parent_id, @source, @config) }
      end.to raise_error(Aperitiiif::Error)
    end

    context 'when given requisite configuration'
    it 'returns asset object' do
      expect(@asset).to be_an(Aperitiiif::Asset)
    end
  end

  describe '.id' do
  end

  describe '.target' do
  end

  describe '.width' do
    it 'returns asset width as int' do
      expect(@asset.width).to eq(1686)
    end
  end

  describe '.height' do
    it 'returns asset height as int' do
      expect(@asset.height).to eq(3000)
    end
  end

  describe '.target_mime' do
    it 'returns tiff mime string' do
      expect(@asset.target_mime).to eq('image/jpeg')
    end
  end

  describe '.source_mime' do
    it 'returns jpeg mime string' do
      expect(@asset.source_mime).to eq('image/jpeg')
    end
  end

  describe '.canvas_url' do
    it 'returns valid url' do
      expect(@asset.canvas_url).to start_with('https://example.com/presentation/')
    end
  end

  describe '.thumbnail_url' do
    it 'returns expected url' do
      expect(@asset.thumbnail_url).to start_with('https://example.com/presentation/')
    end
  end

  describe '.annotation_url' do
    it 'returns expected url' do
      expect(@asset.annotation_url).to start_with('https://example.com/presentation/')
    end
  end

  describe '.full_resource_url' do
    it 'returns expected url' do
      expect(@asset.full_resource_url).to start_with('https://example.com/presentation/')
    end
  end

  describe '.service_url' do
    it 'returns expected url' do
      expect(@asset.service_url).to start_with('https://example.com/presentation/')
    end
  end

  describe '.write_to_target' do
    context 'if target file already exists' do
      it 'skips writing' do
        @asset.write_to_target
        expect(@asset.target_written?).to be(true)
        expect(@asset.write_to_target).to be(false)
      end
    end
    context 'if target file does not exist' do
      it 'writes the file' do
        FileUtils.rm(@asset.target) if @asset.target_written?
        @asset.write_to_target
        expect(@asset.target_written?).to be(true)
      end
    end
  end

  describe '.service' do
    it 'returns a hash' do
      expect(@asset.service).to be_a(Hash)
    end
  end

  describe '.annotation' do
    it 'returns a iiif annotation' do
      expect(@asset.annotation).to be_a(IIIF::Presentation::Annotation)
    end
  end

  describe '.resource' do
    it 'returns a iiif resource' do
      expect(@asset.resource).to be_a(IIIF::Presentation::Resource)
    end
  end

  describe '.canvas' do
    it 'returns a iiif canvas' do
      expect(@asset.canvas).to be_a(IIIF::Presentation::Canvas)
    end
  end
end
