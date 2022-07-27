# frozen_string_literal: true

require 'ostruct'

# TO DO COMMENT
module Apertiiif
  # TO DO COMMENT
  class Config
    DEFAULT_VALUES = {
      'build_dir' => './build',
      'source_dir' => './src/data',
      'service_namespace' => 'apertiiif-batch'
    }.freeze

    def initialize(seed = {})
      @hash   = DEFAULT_VALUES.merge(seed)
      @source = OpenStruct.new @hash

      validate
    end

    def method_missing(method, *args, &block)
      @source.send(method, *args, &block)
    end

    def respond_to_missing?(method_name)
      @source.send(method) || super
    end

    # should check for more reqs
    def validate
      raise Apertiiif::Error, "Config is missing a valid 'namespace' for the batch." if batch_namespace.empty?
      raise Apertiiif::Error, "Config is missing 'label' for the batch," if batch_label.empty?
    end

    def batch_namespace
      pwd  = FileUtils.pwd
      name = pwd.split(@source.service_namespace).last
      Utils.prune_prefix_junk name
    end

    def batch_label
      label
    end

    def presentation_build_dir
      "#{build_dir}/presentation"
    end

    def image_build_dir
      "#{build_dir}/image"
    end

    def html_build_dir
      "#{build_dir}/html"
    end

    def records_file
      @hash.dig('records', 'file') || ''
    end

    def records_defaults
      @hash.dig('records', 'defaults') || {}
    end
  end
end
