# frozen_string_literal: true

require 'fileutils'
require 'parallel'
require 'progress_bar'
require 'safe_yaml'

require 'apertiiif/batch/assets'
require 'apertiiif/batch/items'
require 'apertiiif/batch/records'
require 'apertiiif/batch/index'
require 'apertiiif/batch/linters'

# TO DO COMMENT
module Apertiiif
  # TO DO COMMENT
  class Batch
    include Assets
    include Index
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
      puts Rainbow('Resetting build...').cyan
      FileUtils.rm_rf dir
      puts Rainbow('Done ✓').green
    end

    def write_target_assets(assets = self.assets)
      bar = ProgressBar.new :rate
      puts Rainbow('Writing target image TIFs...').cyan
      Parallel.each assets do |asset|
        asset.write_to_target
        bar.increment!
      end
      puts Rainbow("\nDone ✓").green
    end

    # has smell :reek:TooManyStatements
    def write_presentation_json(items = self.items)
      bar = ProgressBar.new :rate
      puts Rainbow('Creating IIIF Presentation JSON...').cyan
      load_records!
      Parallel.each items do |item|
        item.write_presentation_json && bar.increment!
      end
      write_iiif_collection_json
      puts Rainbow("\nDone ✓").green
    end

    def seed
      {
        '@id' => iiif_collection_url,
        'label' => config.batch_label,
        'description' => config.batch_description,
        'attribution' => config.batch_attribution
      }.delete_if { |_key, val| val.blank? }
    end

    def iiif_collection
      collection = IIIF::Presentation::Collection.new seed
      collection.manifests = items.map(&:manifest)
      collection
    end

    def iiif_collection_file
      "#{config.presentation_build_dir}/#{config.batch_namespace}/collection.json"
    end

    def iiif_collection_url
      "#{config.presentation_api_url}/#{config.batch_namespace}/collection.json"
    end

    def write_iiif_collection_json
      FileUtils.mkdir_p File.dirname(iiif_collection_file)
      File.open(iiif_collection_file, 'w') { |file| file.write iiif_collection.to_json(pretty: true) }
    end
  end
end
