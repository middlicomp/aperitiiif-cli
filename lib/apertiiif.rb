# frozen_string_literal: true

require 'thor'

require_relative 'apertiiif/batch'
require_relative 'apertiiif/version'
require_relative 'apertiiif/utils'

# TO DO COMMENT
module Apertiiif
  # TO DO COMMENT
  class Error < StandardError; end

  # TO DO COMMENT
  class BatchBuilder < Thor
    map %w[--version -v] => :__print_version
    desc '--version, -v', 'print the version'
    def __print_version
      puts Apertiiif::VERSION
    end

    desc 'build', 'build the batch'
    option :reset
    def build
      batch = Apertiiif::Batch.new
      batch.reset if options[:reset]
      batch.build_image_api
      batch.build_presentation_api
      # batch.validate
    end
  end
end
