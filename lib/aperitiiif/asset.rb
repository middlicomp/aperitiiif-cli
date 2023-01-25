# frozen_string_literal: true

require 'iiif/presentation'
require 'mimemagic'
require 'vips'

# to do
module Aperitiiif
  # to do
  # has smell :reek:TooManyMethods
  class Asset
    attr_reader :parent_id

    TARGET_EXT  = '.tif'
    TARGET_OPTS = { tile: :pyramid, compression: :jpeg, tile_width: 256, tile_height: 256 }.freeze

    def initialize(parent_id, source, config)
      @parent_id  = parent_id
      @source     = source
      @config     = config

      validate_source
      validate_config
    end

    def validate_source
      raise Aperitiiif::Error, "Asset source #{@source} does not exist" unless File.file? @source
      raise Aperitiiif::Error, "Asset source #{@source} is not a valid format" unless Utils.valid_source? @source
    end

    def validate_config
      raise Aperitiiif::Error, "No value found for 'namespace'. Check your config?" if @config.namespace.empty?
      raise Aperitiiif::Error, "No value found for 'image_build_dir'. Check your config?" if @config.image_build_dir.empty?
      raise Aperitiiif::Error, "No value found for 'presentation_api_url'. Check your config?" if @config.presentation_api_url.empty?
      raise Aperitiiif::Error, "No value found for 'image_api_url'. Check your config?" if @config.image_api_url.empty?
    end

    def id
      @id ||= build_id
    end

    def target
      @target ||= build_target
    end

    def width
      @width ||= Vips::Image.new_from_file(@source).width
    end

    def height
      @height ||= Vips::Image.new_from_file(@source).height
    end

    def target_mime
      write_to_target
      @target_mime ||= Utils.mime target
    end

    def source_mime
      @source_mime ||= Utils.mime @source
    end

    def canvas_url
      @canvas_url ||= "#{@config.presentation_api_url}/canvas/#{id}.json"
    end

    def thumbnail_url
      @thumbnail_url ||= "#{@config.image_api_url}/#{id}/square/250,/0/default.jpg"
    end

    def annotation_url
      @annotation_url ||= "#{@config.presentation_api_url}/annotation/#{id}.json"
    end

    def full_resource_url
      @full_resource_url ||= "#{@config.image_api_url}/#{id}/full/full/0/default.jpg"
    end

    def service_url
      @service_url ||= "#{@config.image_api_url}/#{id}"
    end

    def build_id
      id = Utils.basename_no_ext @source
      id.prepend "#{@parent_id}_" unless id == @parent_id
      id.prepend "#{@config.namespace}_"
    end

    def target_written? = File.file? target

    def build_target = "#{@config.image_build_dir}/#{id}#{TARGET_EXT}"

    def write_to_target
      return false if target_written?

      FileUtils.mkdir_p @config.image_build_dir
      Vips::Image.new_from_file(@source).tiffsave target, **TARGET_OPTS
      GC.start
    end

    def service
      {
        '@context' => 'http://iiif.io/api/image/2/context.json',
        '@id' => service_url
      }
    end

    def annotation
      opts = {
        '@id' => annotation_url,
        'on' => canvas_url,
        'resource' => resource
      }
      IIIF::Presentation::Annotation.new opts
    end

    def resource
      opts = {
        '@id' => full_resource_url,
        '@type' => 'dcterms:Image',
        'service' => service,
        'format' => target_mime
      }
      IIIF::Presentation::Resource.new opts
    end

    def canvas
      opts = {
        '@id' => canvas_url,
        'label' => id,
        'width' => width,
        'height' => height,
        'thumbnail' => thumbnail_url,
        'images' => [annotation]
      }
      IIIF::Presentation::Canvas.new opts
    end
  end
end
