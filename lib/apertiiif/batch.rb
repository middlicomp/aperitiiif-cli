# frozen_string_literal: true

require 'fileutils'
require 'parallel'
require 'ruby-progressbar'
require 'safe_yaml'

require 'apertiiif/batch/assets'
require 'apertiiif/batch/items'
require 'apertiiif/batch/records'
require 'apertiiif/batch/linters'

# TO DO COMMENT
module Apertiiif
  # TO DO COMMENT
  class Batch
    include Assets
    include Items
    include Linters
    include Records

    def initialize; end

    DEFAULT_CONFIG_FILE = './config.yml'

    def config
      @config ||= load_config_file
    end

    def load_config_file(file = DEFAULT_CONFIG_FILE)
      @config = Config.new SafeYAML.load_file file
    rescue StandardError
      raise Apertiiif::Error, "Cannot find file #{file}" unless File.file?(file)

      raise Apertiiif::Error, "Cannot read file #{file}. Is it valid yaml?"
    end

    def load_config_hash(hash)
      @config = Config.new hash
    end

    def reset(dir = config.build_dir)
      print 'Resetting build...'.colorize(:cyan)
      FileUtils.rm_rf dir
      print("\r#{'Resetting build:'.colorize(:cyan)} #{'Done ✓'.colorize(:green)}")
    end

    def write_target_assets(assets = self.assets)
      msg = 'Writing target image TIFs'.colorize(:cyan)
      Parallel.map(assets, in_threads: 4, progress: { format: "#{msg}: %c/%u | %P%" }, &:write_to_target)
    end

    # has smell :reek:TooManyStatements
    def write_presentation_json(items = self.items)
      msg = 'Writing IIIF Presentation JSON'.colorize(:cyan)
      load_records!
      Parallel.map(items, in_threads: 4, progress: { format: "#{msg}: %c/%u | %P%" }, &:write_presentation_json)
      write_iiif_collection_json
    end

    def seed
      {
        '@id' => iiif_collection_url,
        'label' => config.label,
        'description' => config.batch_description,
        'attribution' => config.batch_attribution
      }.delete_if { |_key, val| val.blank? }
    end

    def iiif_collection
      collection = IIIF::Presentation::Collection.new seed
      collection.manifests = items.map(&:manifest)
      collection
    end

    def iiif_collection_file      = "#{config.presentation_build_dir}/#{config.namespace}/collection.json"
    def iiif_collection_url       = "#{config.presentation_api_url}/#{config.namespace}/collection.json"
    def iiif_collection_written?  = File.file? iiif_collection_file

    def write_iiif_collection_json
      Apertiiif::Utils.mkfile_p iiif_collection_file, iiif_collection.to_json(pretty: true)
    end
  end
end
