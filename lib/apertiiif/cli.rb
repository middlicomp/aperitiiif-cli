# frozen_string_literal: true

require 'safe_yaml'

require_relative 'cli/version'
require_relative 'cli/ingest'

# TO DO COMMENT
module Apertiiif
  # TO DO COMMENT
  module Cli
    class Error < StandardError; end

    CONFIG_FILE = './config.yml'
    CONFIG      = SafeYAML.load_file CONFIG_FILE
  end
end
