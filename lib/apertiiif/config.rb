# frozen_string_literal: true

# TO DO COMMENT
module Apertiiif
  # TO DO COMMENT
  class Config
    DEFAULT_CONFIG_FILE  = './config.yml'
    DEFAULT_BUILD_DIR    = './build'
    DEFAULT_SOURCE_DIR   = './src/data'
    DEFAULT_RECORDS_FILE = './src/records.csv'

    def initialize(config = nil)
      @hash = config || SafeYAML.load_file(DEFAULT_CONFIG_FILE)
    end

    def build_dir
      @hash.fetch 'build_dir', DEFAULT_BUILD_DIR
    end

    def public_dir
      @hash.fetch 'public_dir', DEFAULT_PUBLIC_DIR
    end

    def source_dir
      @hash.fetch 'source_dir', DEFAULT_SOURCE_DIR
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
      @hash.dig 'records', 'file' || DEFAULT_RECORDS_FILE
    end

    def records_defaults
      @hash.dig 'records', 'defaults' || {}
    end

    def image_api_url
      @hash.fetch 'image_api_url'
    end

    def service_namespace
      @hash.fetch 'service_namespace', 'apertiiif-batch'
    end

    def presentation_api_url
      @hash.fetch 'presentation_api_url'
    end

    def batch_namespace
      working_dir = File.basename FileUtils.pwd
      working_dir.sub! service_namespace, ''
      Utils.prune_prefix_junk working_dir
    end

    def batch_label
      @hash.fetch 'label', nil
    end

    def batch_description
      @hash.fetch 'description', nil
    end

    def batch_attribution
      @hash.fetch 'attribution', nil
    end
  end
end
