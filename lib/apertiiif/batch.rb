# frozen_string_literal: true

require 'fileutils'
require 'safe_yaml'

require_relative 'config'
require_relative 'api/image'
require_relative 'api/presentation'

# TO DO COMMENT
module Apertiiif
  # TO DO COMMENT
  class Batch
    include Apertiiif::Api::Image
    include Apertiiif::Api::Presentation

    attr_reader :config

    def initialize(config = nil)
      @config = Apertiiif::Config.new config
    end

    def source_files
      Dir.glob("#{@config.source_dir}/**/*").select { |f| File.file? f }
    end

    def tif_files
      Dir.glob("#{@config.image_build_dir}/**/*").select { |f| File.file? f }
    end
  end
end
