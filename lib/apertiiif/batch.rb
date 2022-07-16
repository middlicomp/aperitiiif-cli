# frozen_string_literal: true

require 'csv'
require 'fileutils'
require 'iiif/presentation'
require 'json'
require 'parallel'
require 'progress_bar'
require 'rainbow'
require 'safe_yaml'

require_relative 'batch/indexable'
require_relative 'batch/lintable'

# TO DO COMMENT
module Apertiiif
  CONFIG  = Apertiiif::Config.new
  FORMATS = %w[jpg jpeg png tif tiff].freeze

  # TO DO COMMENT
  class Batch
    include Indexable
    include Lintable

    def initialize
      @records = records
      @items = items
    end

    def reset
      puts Rainbow('Resetting build...').cyan
      FileUtils.rm_rf CONFIG.build_dir
      puts Rainbow('Done ✓').green
    end

    def collect_assets_paths(path)
      return [path] if File.file?(path) && path.end_with?(*FORMATS)
      return [] unless File.directory? path

      Dir.glob("#{path}/*").select { |p| p.end_with?(*FORMATS) }
    end

    def items
      Dir.glob("#{CONFIG.source_dir}/*").map do |p|
        asset_paths = collect_assets_paths p
        next if asset_paths.empty?

        id          = Apertiiif::Utils.basename p
        record      = @records.find { |r| r.id == id }
        Apertiiif::Item.new id, asset_paths, record
      end.compact
    end

    def records
      hashes = CSV.read(CONFIG.records_file, headers: true).map(&:to_hash)
      hashes.map do |h|
        h = CONFIG.records_defaults.merge h.compact
        OpenStruct.new h
      end
    rescue StandardError
      puts Rainbow("Could not load #{CONFIG.records_file}. Does it exist as a valid CSV?").magenta
      []
    end

    def assets
      @assets ||= @items.flat_map(&:assets)
    end

    def hashes
      @items.map(&:to_hash)
    end

    def seed
      s = {}
      s['@id']         = iiif_collection_url
      s['label']       = CONFIG.batch_label unless CONFIG.batch_label.nil?
      s['description'] = CONFIG.batch_description unless CONFIG.batch_description.nil?
      s['attribution'] = CONFIG.batch_attribution unless CONFIG.batch_attribution.nil?
      s
    end

    def iiif_collection
      c = IIIF::Presentation::Collection.new seed
      c.manifests = @items.map(&:manifest)
      c
    end

    def iiif_collection_file
      "#{CONFIG.presentation_build_dir}/#{CONFIG.batch_namespace}/collection.json"
    end

    def iiif_collection_url
      "#{CONFIG.presentation_api_url}/#{CONFIG.batch_namespace}/collection.json"
    end

    def write_iiif_collection_json
      FileUtils.mkdir_p File.dirname(iiif_collection_file)
      File.open(iiif_collection_file, 'w') { |m| m.write iiif_collection.to_json(pretty: true) }
    end

    def build_image_api
      FileUtils.mkdir_p CONFIG.image_build_dir
      bar = ProgressBar.new :rate
      puts Rainbow('Writing target TIFs...').cyan
      Parallel.each assets do |a|
        a.write_to_target
        bar.increment!
      end
      puts Rainbow("\nDone ✓").green
    end

    def build_presentation_api
      FileUtils.mkdir_p CONFIG.presentation_build_dir
      bar = ProgressBar.new :rate
      puts Rainbow('Creating IIIF Presentation JSON...').cyan
      Parallel.each @items do |i|
        i.write_presentation_json
        bar.increment!
      end
      write_iiif_collection_json
      puts Rainbow("\nDone ✓").green
    end
  end
end
