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
  class CLI < Thor
    map %w[--version -v] => :__print_version
    desc '--version, -v', 'print the version'
    def __print_version
      puts Apertiiif::VERSION
    end

    desc 'build', 'build the batch'
    option :reset
    option :audit
    def build
      batch = Apertiiif::Batch.new
      batch.reset if options[:reset]
      batch.audit_records if options[:audit]
      batch.build_image_api
      batch.build_presentation_api
      batch.build_html_index
      batch.build_json_index
    end
  end
end
