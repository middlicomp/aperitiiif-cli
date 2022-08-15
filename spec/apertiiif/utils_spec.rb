# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Apertiiif::Utils do
  describe '.prune_prefix_junk' do
    it 'removes unwanted starting characters' do
      @str = Apertiiif::Utils.prune_prefix_junk '/\/#./test.file'
      expect(@str).to eq('test.file')
    end
  end

  describe '.formatted_datetime' do
    it 'returns formatted datestring' do
      @time = Time.utc(1991, 10, 4)
      @str  = Apertiiif::Utils.formatted_datetime(@time)
      expect(@str).to eq('10/4/1991 at 0:00UTC')
    end
  end

  describe '.mime' do
    context 'when given a jpeg image path' do
      it 'returns jpeg mime string' do
        @mime = Apertiiif::Utils.mime 'spec/fixtures/src/data/valid/valid.jpeg'
        expect(@mime).to eq('image/jpeg')
      end
    end
  end

  describe '.valid_source?' do
    context 'when given existing jpeg file path' do
      it 'returns true' do
        @path   = 'spec/fixtures/src/data/valid/valid.jpeg'
        @result = Apertiiif::Utils.valid_source? @path
        expect(@result).to be(true)
      end
    end

    context 'when given existing mp3 file path' do
      it 'returns false' do
        @path   = 'spec/fixtures/src/data/invalid/invalid_type.mp3'
        @result = Apertiiif::Utils.valid_source? @path
        expect(@result).to be(false)
      end
    end

    context 'when given nonexisting jpeg file path' do
      it 'returns false' do
        @path   = 'spec/fixtures/nil.jpeg'
        @result = Apertiiif::Utils.valid_source? @path
        expect(@result).to be(false)
      end
    end
  end

  describe '.item_assets_from_path' do
    context 'when given path to a valid image file' do
      it 'returns an array with path as only value' do
        @path   = 'spec/fixtures/src/data/valid/valid.jpeg'
        @result = Apertiiif::Utils.item_assets_from_path @path
        expect(@result).to be_an(Array)
        expect(@result.first).to eq(@path)
      end
    end

    context 'when given path to an invalid image file' do
      it 'returns an empty array' do
        @path = 'spec/fixtures/src/data/invalid/invalid_type.mp3'
        @result = Apertiiif::Utils.item_assets_from_path @path
        expect(@result).to be_an(Array)
        expect(@result).to be_empty
      end
    end

    context 'when given path to a directory of valid image files' do
      it 'returns an array with image file paths as values' do
        @path = 'spec/fixtures/data/valid/dir'
        @result = Apertiiif::Utils.item_assets_from_path @path
        expect(@result).to be_an(Array)
        expect(@result).to all be_a(String)
      end
    end

    context 'when given path to a directory of invalid image files' do
      it 'returns an empty array' do
        @path = 'spec/fixtures/data/invalid/dir'
        @result = Apertiiif::Utils.item_assets_from_path @path
        expect(@result).to be_an(Array)
        expect(@result).to be_empty
      end
    end
  end

  describe '.csv_records' do
    context 'when given a valid csv file' do
      before(:example) do
        @path = 'spec/fixtures/src/valid.csv'
      end
      it 'returns an array of records' do
        @result = Apertiiif::Utils.csv_records @path
        expect(@result).to all be_an(Apertiiif::Record)
      end
      context 'when given defaults to load' do
        it 'sets the defaults without overriding existing fields' do
          @defaults = { 'new_field' => 'test', 'description' => 'set_if_empty' }
          @result   = Apertiiif::Utils.csv_records @path, @defaults
          expect(@result).to all be_an(Apertiiif::Record)
          expect(@result.first.new_field).to eq('test')
          expect(@result.first.description).to eq('set_if_empty')
          expect(@result.last.description).to eq('original description')
        end
      end
    end

    context 'when given an invalid csv file' do
      it 'raises a custom error' do
        @path = 'spec/fixtures/src/invalid.csv'
        expect do
          quiet_stdout { Apertiiif::Utils.csv_records(@path) }
        end.to raise_error(Apertiiif::Error)
      end
    end
  end
end
