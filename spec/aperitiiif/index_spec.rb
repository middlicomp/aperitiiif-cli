# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Aperitiiif::Index do
  before(:all) do
    @batch = Aperitiiif::Batch.new
    @batch.load_config_file 'spec/fixtures/config.yml'
    @index = Aperitiiif::Index.new(@batch)
  end

  describe '.new' do
    it 'returns an index' do
      expect(Aperitiiif::Index.new(@batch)).to be_an(Aperitiiif::Index)
    end
  end

  describe '.path' do
  end

  describe '.write' do
    context 'when given :html :type option' do
      context 'when given a custom path' do
        it 'writes html index to the custom path' do
          @path = 'build/custom-index-test.html'
          quiet_stdout { @index.write type: :html, path: @path }
          expect(File.file?(@path)).to be
        end
      end
      context 'when not given a path' do
        it 'writes html index to the default path' do
          @path = @index.path :html
          quiet_stdout { @index.write type: :html }
          expect(File.file?(@path)).to be
        end
      end
    end
    context 'when given :json :type option' do
      context 'when given a custom path' do
        it 'writes json index to the custom path' do
          @path = 'build/custom-index-test.json'
          quiet_stdout { @index.write type: :json, path: @path }
          expect(File.file?(@path)).to be
        end
      end
      context 'when not given a path' do
        it 'writes json index to the default path' do
          @path = @index.path :json
          quiet_stdout { @index.write type: :json }
          expect(File.file?(@path)).to be
        end
      end
    end
    context 'when given an invalid :type option' do
      it 'raises custom error' do
        quiet_stdout do
          expect { @index.write type: :baddy }.to raise_error(Aperitiiif::Error)
        end
      end
    end
    context 'when not given a :type option' do
      it 'raises custom error' do
        quiet_stdout do
          expect { @index.write }.to raise_error(Aperitiiif::Error)
        end
      end
    end
  end

  describe '.to_json' do
    it 'returns the batch items represented as a JSON string' do
      expect(@index.to_json).to be_a(String)
    end
  end

  describe '.to_html' do
    it 'returns the batch items represented as an HTML string' do
      expect(@index.to_html).to be_a(String)
    end
  end
end
