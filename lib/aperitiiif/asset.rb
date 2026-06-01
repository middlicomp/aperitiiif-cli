# frozen_string_literal: true

require 'iiif/presentation'
require 'mimemagic'
require 'vips'

# to do
module Aperitiiif
  # to do
  class Asset
    attr_reader :parent_id

    FORMAT_EXTS = { 'tif' => '.tif', 'jpg' => '.jpg' }.freeze
    TIFF_OPTS    = { tile: :pyramid, compression: :jpeg, tile_width: 256, tile_height: 256 }.freeze
    JPEG_OPTS    = { Q: 90 }.freeze

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
      raise Aperitiiif::Error, "Unsupported image output format '#{image_output_format}'. Check your config?" unless FORMAT_EXTS.key?(image_output_format)
    end

    def id
      @id ||= build_id
    end

    def target
      @target ||= build_target
    end

    def image_output_format
      @config.image_output_format
    end

    def target_ext
      FORMAT_EXTS.fetch(image_output_format)
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

    def metadata
      {
        'id' => id,
        'source' => @source,
        'target' => target,
        'width' => width,
        'height' => height,
        'source_mime' => source_mime,
        'target_mime' => target_mime,
        'target_written' => target_written?
      }
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
      @full_resource_url ||= "#{@config.image_api_url}/#{id}/full/max/0/default.jpg"
    end

    def service_url
      @service_url ||= "#{@config.image_api_url}/#{id}"
    end

    def build_id
      id = Utils.basename_no_ext @source
      id.prepend "#{@parent_id}/" unless id == @parent_id
      id.prepend "#{@config.namespace}/"
    end

    def target_written? = File.file? target

    def build_target
      "#{@config.image_build_dir}/#{id}#{target_ext}"
    end

    def target_opts
      image_output_format == 'jpg' ? JPEG_OPTS : TIFF_OPTS
    end

    def write_to_target
      return false if target_written?

      FileUtils.mkdir_p File.dirname(target)
      image = Vips::Image.new_from_file(@source)
      if image_output_format == 'jpg'
        image.jpegsave target, **target_opts
      else
        image.tiffsave target, **target_opts
      end
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
