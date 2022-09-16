# frozen_string_literal: true

require 'ostruct'

# to do
module Aperitiiif
  # to do
  class Record
    DELEGATE                = %i[puts p].freeze
    CUSTOM_METADATA_PREFIX  = 'meta.'

    def initialize(hash, defaults = {})
      @hash = defaults.merge(hash)
      @id   = id
    end

    def method_missing(method, *args, &block)
      return super if DELEGATE.include? method

      @hash.fetch method.to_s
    end

    def respond_to_missing?(method, _args)
      DELEGATE.include?(method) or super
    end

    def id
      @hash.fetch 'id'
    rescue KeyError
      raise Aperitiiif::Error, "Record has no 'id'\n#{@hash.inspect}"
    end

    def label       = @hash.fetch 'label', id
    def logo        = @hash.fetch 'logo', ''
    def description = @hash.fetch 'description', ''
    def source      = @hash.fetch 'source', ''

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
  end
end
