# frozen_string_literal: true

require 'iiif/presentation'
require 'ostruct'
require 'json'
require 'aperitiiif/asset'

# to do
module Aperitiiif
  # to do
  class Item
    attr_writer :record
    attr_reader :id, :asset_paths

    def initialize(id, asset_paths, config, checkpoint: {})
      @id          = id
      @config      = config
      @asset_paths = normalize_asset_paths(asset_paths)
      @checkpoint  = checkpoint || {}

      validate_config
    end

    def normalize_asset_paths(paths)
      Array(paths).map do |path|
        next path if path.is_a?(String)

        path.respond_to?(:instance_variable_get) ? path.instance_variable_get(:@source) : path.to_s
      end
    end

    def validate_config
      raise Aperitiiif::Error, "No value found for 'namespace'. Check your config?" if @config.namespace.empty?
      raise Aperitiiif::Error, "No value found for 'presentation_api_url'. Check your config?" if @config.presentation_api_url.empty?
      raise Aperitiiif::Error, "No value found for 'presentation_build_dir'. Check your config?" if @config.presentation_build_dir.empty?
    end

    def record
      @record || default_record
    end

    def default_record
      Record.new({ 'id' => id }, @config.records_defaults)
    end

    def assets
      @assets ||= asset_paths.map { |path| Asset.new id, path, @config }
    end

    def asset_count
      @checkpoint['asset_count'] || asset_paths.count
    end

    def asset_metadata
      return assets.map(&:metadata) unless uses_checkpoint?

      @checkpoint['assets']
    end

    def uses_checkpoint?
      @checkpoint.is_a?(Hash) && @checkpoint.key?('assets') && @checkpoint['assets'].is_a?(Array)
    end

    def manifest
      @manifest ||= build_manifest
    end

    def label
      record.label
    end

    def manifest_url
      "#{@config.presentation_api_url}/#{@config.namespace}/#{@id}/manifest.json"
    end

    def full_url
      return '' if asset_metadata.empty?

      first = asset_metadata.first
      "#{@config.image_api_url}/#{first['id']}/full/full/0/default.jpg"
    end

    def thumbnail_url
      return '' if asset_metadata.empty?

      first = asset_metadata.first
      "#{@config.image_api_url}/#{first['id']}/square/250,/0/default.jpg"
    end

    def viewpoint_url
      "https://middlicomp.github.io/viewpoint/mirador/#manifests[]=#{CGI.escape manifest_url}&theme=light&thumbs=bottom&view=single&workspacecontrols=false"
    end

    def seed
      {
        '@id' => manifest_url,
        'label' => label,
        'logo' => record.logo,
        'description' => record.description,
        'source' => record.source,
        'metadata' => record.custom_metadata
      }.delete_if { |_key, val| val.to_s.empty? }
    end

    def build_manifest
      manifest = IIIF::Presentation::Manifest.new seed
      sequence = IIIF::Presentation::Sequence.new
      sequence.canvases = canvases
      manifest.sequences << sequence
      manifest
    end

    def canvases
      return assets.map(&:canvas) unless uses_checkpoint?

      asset_metadata.map { |metadata| build_canvas_from_metadata(metadata) }
    end

    def build_canvas_from_metadata(metadata)
      IIIF::Presentation::Canvas.new(
        '@id' => canvas_url_for(metadata['id']),
        'label' => metadata['id'],
        'width' => metadata['width'],
        'height' => metadata['height'],
        'thumbnail' => thumbnail_url_for(metadata['id']),
        'images' => [build_annotation_from_metadata(metadata)]
      )
    end

    def build_annotation_from_metadata(metadata)
      IIIF::Presentation::Annotation.new(
        '@id' => annotation_url_for(metadata['id']),
        'on' => canvas_url_for(metadata['id']),
        'resource' => build_resource_from_metadata(metadata)
      )
    end

    def build_resource_from_metadata(metadata)
      IIIF::Presentation::Resource.new(
        '@id' => full_resource_url_for(metadata['id']),
        '@type' => 'dcterms:Image',
        'service' => {
          '@context' => 'http://iiif.io/api/image/2/context.json',
          '@id' => service_url_for(metadata['id'])
        },
        'format' => metadata['target_mime']
      )
    end

    def canvas_url_for(asset_id)
      "#{@config.presentation_api_url}/canvas/#{asset_id}.json"
    end

    def annotation_url_for(asset_id)
      "#{@config.presentation_api_url}/annotation/#{asset_id}.json"
    end

    def service_url_for(asset_id)
      "#{@config.image_api_url}/#{asset_id}"
    end

    def full_resource_url_for(asset_id)
      "#{@config.image_api_url}/#{asset_id}/full/full/0/default.jpg"
    end

    def thumbnail_url_for(asset_id)
      "#{@config.image_api_url}/#{asset_id}/square/250,/0/default.jpg"
    end

    def manifest_file
      "#{@config.presentation_build_dir}/#{@config.namespace}/#{id}/manifest.json"
    end

    def manifest_written?
      File.file? manifest_file
    end

    def checkpoint_dir
      "#{@config.build_dir}/.checkpoint/items"
    end

    def checkpoint_file
      "#{checkpoint_dir}/#{id}.json"
    end

    def checkpoint_data
      {
        'id' => id,
        'asset_count' => asset_count,
        'assets' => asset_metadata,
        'manifest_written' => manifest_written?,
        'updated_at' => Time.now.utc.iso8601
      }
    end

    def write_checkpoint!
      FileUtils.mkdir_p checkpoint_dir
      File.write(checkpoint_file, JSON.pretty_generate(checkpoint_data))
    end

    def needs_manifest?
      !manifest_written?
    end

    def write_target_assets
      assets.each do |asset|
        asset.write_to_target
        write_checkpoint!
      end
    end

    def write_presentation_json
      return false unless needs_manifest?

      Aperitiiif::Utils.mkfile_p manifest_file, manifest.to_json(pretty: true)
      write_checkpoint!
    end

    def to_hash
      {
        'id' => id,
        'label' => label,
        'manifest_url' => manifest_url,
        'thumbnail_url' => thumbnail_url,
        'full_url' => full_url,
        'viewpoint_url' => viewpoint_url
      }
    end
  end
end
