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
      @str = Apertiiif::Utils.formatted_datetime(Time.new(1991, 10, 14))
      expect(@str).to eq('10/14/1991 at 0:00EDT')
    end
  end

  describe '.mime' do
    context 'when given a jpeg image path' do
      it 'returns jpeg mime string' do
        @mime = Apertiiif::Utils.mime 'spec/fixtures/001.jpeg'
        expect(@mime).to eq('image/jpeg')
      end
    end
  end

  describe 'valid_source?' do
    # File.file?(path) && path.end_with?(*ALLOWED_SRC_FORMATS)
  end

  describe 'item_assets_from_path' do
    # return [path] if Utils.valid_source?(path)
    # return [] unless File.directory? path
    #
    # Dir.glob("#{path}/*").select { |sub| Utils.valid_source? sub }
  end

  describe 'csv_records' do
    #   hashes = CSV.read(file, headers: true).map(&:to_hash)
    #   hashes.map { |hash| Record.new hash, defaults }
    # rescue StandardError
    #   raise Apertiiif::Error, "Found file #{file} but could not read it. Is it a valid CSV?"
  end
end
