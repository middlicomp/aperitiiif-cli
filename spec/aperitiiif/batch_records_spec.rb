# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Aperitiiif::Records do
  before(:all) do
    @batch = Aperitiiif::Batch.new
    @batch.load_config_file 'spec/fixtures/config.yml'
  end

  describe '.records' do
    it 'returns an array of records' do
      expect(@batch.records.first).to be_an(Aperitiiif::Record)
    end
  end

  describe '.find_record' do
    context 'when given a record id that exists' do
      it 'returns the record' do
        @id = 'valid'
        expect(@batch.find_record(@id)).to be_an(Aperitiiif::Record)
      end
    end
    context 'when given a record id that does not exist' do
      it 'returns nil' do
        @id = 'nil-id'
        expect(@batch.find_record(@id)).to be_nil
      end
    end
  end

  describe '.records_from_file' do
    context 'when no records file is configured' do
      it 'returns an empty array' do
        @file = nil
        quiet_stdout { expect(@batch.records_from_file(@file)).to be_empty }
      end
    end
    context 'when the configured records file does not exist' do
      it 'returns an empty array' do
        @file = 'spec/not-exist.csv'
        quiet_stdout { expect(@batch.records_from_file(@file)).to be_empty }
      end
    end
    context 'when the configured records file exists' do
      it 'returns an array of records' do
        expect(@batch.records_from_file.first).to be_an(Aperitiiif::Record)
      end
    end
  end

  describe '.records_file_configured?' do
  end

  describe '.records_file_exists?' do
  end

  describe '.load_records!' do
    it 'adds records to existing items' do
      @default_label = @batch.items.first.record.id
      @start_label = 'Acteur'
      expect(@batch.items.first.record.label).to eq(@default_label)
      @batch.load_records!
      expect(@batch.items.first.record.label).to start_with(@start_label)
    end
  end
end
