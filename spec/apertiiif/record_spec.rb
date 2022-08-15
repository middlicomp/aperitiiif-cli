# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Apertiiif::Record do
  before(:context) do
    @hash         = { 'id' => 'myid', 'shared_key' => 'keep me' }
    @defaults     = { 'shared_key' => 'discard me', 'new_key' => 'add me' }
    @record       = Apertiiif::Record.new @hash, @defaults
    @custom_meta  = { 'id' => 'myid', 'meta.test' => true, 'META.test' => false, 'meta test' => false }
  end
  describe '.new' do
    context 'when given a valid hash' do
      it 'creates a record object' do
        expect(@record).to be_an(Apertiiif::Record)
      end

      context 'when given defaults' do
        it 'does not override existing keys' do
          expect(@record.shared_key).to eq('keep me')
        end
        it 'adds new keys' do
          expect(@record.new_key).to eq('add me')
        end
      end
    end
    context 'when given an invalid hash (without an id)' do
      it 'raises custom error' do
        @hash = { 'bad' => true }
        expect do
          quiet_stdout { Apertiiif::Record.new(@hash) }
        end.to raise_error(Apertiiif::Error)
      end
    end
  end

  describe '.label' do
    context 'when none is set' do
      it 'returns the id field' do
        expect(@record.label).to eq('myid')
      end
    end
  end

  describe '.logo' do
    context 'when none is set' do
      it 'returns empty string' do
        expect(@record.logo).to be_empty
      end
    end
  end

  describe '.description' do
    context 'when none is set' do
      it 'returns empty string' do
        expect(@record.description).to be_empty
      end
    end
  end

  describe '.source' do
    context 'when none is set' do
      it 'returns empty string' do
        expect(@record.source).to be_empty
      end
    end
  end

  describe '.custom_metadata_keys' do
    context 'with meta prefixed keys' do
      it 'returns array of key strings' do
        @record = Apertiiif::Record.new @custom_meta
        expect(@record.custom_metadata_keys.first).to eq('meta.test')
      end
    end
    context 'without meta prefixed keys' do
      it 'returns an empty array' do
        expect(@record.custom_metadata_keys).to be_empty
      end
    end
  end

  describe '.custom_metadata' do
    context 'with meta prefixed keys' do
      it 'returns array of hashes' do
        @record = Apertiiif::Record.new @custom_meta
        expect(@record.custom_metadata.first).to be_a(Hash)
        expect(@record.custom_metadata.first['label']).to eq('test')
        expect(@record.custom_metadata.first['value']).to be(true)
      end
    end
    context 'without meta prefixed keys' do
      it 'returns an empty array' do
        expect(@record.custom_metadata).to be_empty
      end
    end
  end
end
