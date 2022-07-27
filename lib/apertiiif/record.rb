# frozen_string_literal: true

require 'ostruct'

# to do
module Apertiiif
  # to do
  class Record
    CUSTOM_METADATA_PREFIX = 'meta.'

    def initialize(hash, defaults)
      @hash = defaults.merge(hash)

      validate
    end

    def method_missing(method)
      @hash.fetch method, ''
    end

    def respond_to_missing?(method, _args)
      @hash.send(method) || super
    end

    def id
      @hash.fetch 'id'
    end

    def label
      @hash.fetch 'label', id
    end

    def logo
      @hash.fetch 'logo', ''
    end

    def description
      @hash.fetch 'description', ''
    end

    def source
      @hash.fetch 'source', ''
    end

    def custom_metadata_keys
      @hash.to_h.keys.select { |key| key.to_s.start_with?(CUSTOM_METADATA_PREFIX) } || []
    end

    def custom_metadata
      custom_metadata_keys.map do |key|
        {
          'label' => key.to_s.delete_prefix(CUSTOM_METADATA_PREFIX),
          'value' => @hash[key]
        }
      end
    end

    # should check for more reqs
    def validate
      raise Apertiiif::Error, "Record has no 'id'\n#{@hash.inspect}" unless id.present?
    end
  end
end
