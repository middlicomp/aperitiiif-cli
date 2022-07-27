# frozen_string_literal: true

require 'iiif/presentation'
require 'ostruct'

# to do
module Apertiiif
  # to do
  # has smell :reek:InstanceVariableAssumption
  # has smell :reek:TooManyInstanceVariables
  # has smell :reek:TooManyMethods
  class Item
    # has smell  :reek:Attribute
    attr_writer :record
    attr_reader :id, :assets

    IIIF_LOGO = 'https://upload.wikimedia.org/wikipedia/commons/e/e8/International_Image_Interoperability_Framework_logo.png'

    def initialize(id, assets, config)
      @id       = id
      @config   = config
      @assets   = assets
    end

    def record
      @record || default_record
    end

    def default_record
      Record.new({ 'id' => id }, @config.records_defaults)
    end

    def manifest
      @manifest ||= build_manifest
    end

    def label
      record.label
    end

    def manifest_url
      "#{@config.presentation_api_url}/#{@config.batch_namespace}/#{@id}/manifest.json"
    end

    def thumbnail_url
      assets.first.thumbnail_url
    end

    def viewpoint_url
      "https://dss.hosting.nyu.edu/viewpoint/mirador/#manifests[]=#{CGI.escape manifest_url}&theme=dark"
    end

    # has smell :reek: TooManyStatements
    def seed
      {
        '@id' => manifest_url,
        'label' => label,
        'logo' => record.logo,
        'description' => record.description,
        'source' => record.source,
        'metadata' => record.custom_metadata
      }.delete_if { |_key, val| val.blank? }
    end

    def build_manifest
      manifest = IIIF::Presentation::Manifest.new seed
      sequence = IIIF::Presentation::Sequence.new
      sequence.canvases = assets.map(&:canvas)
      manifest.sequences << sequence
      manifest
    end

    def manifest_file
      "#{@config.presentation_build_dir}/#{@config.batch_namespace}/#{id}/manifest.json"
    end

    def write_presentation_json
      FileUtils.mkdir_p File.dirname(manifest_file)
      File.open(manifest_file, 'w') { |file| file.write manifest.to_json(pretty: true) }
    end

    def to_hash
      {
        'id' => id,
        'manifest' => manifest_url,
        'thumbnail' => assets.first.thumbnail_url
      }
    end

    def to_html_list_item
      <<~HTML
        <tr>
          <td><b>#{id}</b></td>
          <td>#{label}</td>
          <td><a target='_blank' href='#{thumbnail_url}'><img style="height:100px;width:auto" class='lazy' data-original="#{thumbnail_url}"/></a></td>
          <td><a target='_blank' href='#{manifest_url}'><img alt='Thumbnail #{label}' src="#{IIIF_LOGO}" style="width:25px"/></a></td>
          <td><a target='_blank' class='is-size-7' href='#{viewpoint_url}'>#{viewpoint_url}</a></td>
        </tr>
      HTML
    end
  end
end
