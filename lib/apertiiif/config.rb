# frozen_string_literal: true

# TO DO COMMENT
module Apertiiif
  # TO DO COMMENT
  class Config
    CONFIG_FILE = './config.yml'

    def initialize(config = nil)
      @hash = config || SafeYAML.load_file(CONFIG_FILE)
    end

    def build_dir
      @hash.fetch 'build_dir'
    end

    def presentation_build_dir
      "#{build_dir}/presentation"
    end

    def image_build_dir
      "#{build_dir}/image"
    end

    def image_api_url
      @hash.fetch 'image_api_url'
    end

    def service_namespace
      @hash.fetch 'service_namespace'
    end

    def source_dir
      @hash.fetch 'source_dir'
    end

    def presentation_api_url
      @hash.fetch 'presentation_api_url'
    end

    def batch_namespace
      File.basename(FileUtils.pwd).sub(service_namespace, '')
    end
  end
end
