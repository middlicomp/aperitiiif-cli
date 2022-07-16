# frozen_string_literal: true

require 'iiif/presentation'

# to do
module Apertiiif
  # to do
  class Item
    attr_reader :id, :assets, :record

    CUSTOM_METADATA_PREFIX = 'meta.'

    def initialize(id, assets, record = nil)
      @id       = id
      @assets   = assets.map { |a| Apertiiif::Asset.new a }
      @record   = record
      @seed     = seed
    end

    def manifest_url
      "#{CONFIG.presentation_api_url}/#{CONFIG.batch_namespace}/#{@id}/manifest.json"
    end

    def manifest
      @manifest ||= build_manifest
    end

    def viewpoint_url
      "https://dss.hosting.nyu.edu/viewpoint/mirador/#manifests[]=#{CGI.escape manifest_url}&theme=dark"
    end

    def label
      @record&.label || @id
    end

    def logo
      @record&.logo || nil
    end

    def description
      @record&.description || nil
    end

    def source
      @record&.source || nil
    end

    # rubocop:disable Metrics/AbcSize
    def seed
      s                 = {}
      s['@id']          = manifest_url
      s['label']        = label
      s['logo']         = logo unless logo.nil?
      s['description']  = description unless description.nil?
      s['source']       = source unless source.nil?
      s['metadata']     = custom_metadata || []
      s
    end
    # rubocop:enable Metrics/AbcSize

    def custom_metadata_keys
      @record.to_h.keys.select { |k| k.to_s.start_with?(CUSTOM_METADATA_PREFIX) } || []
    end

    def custom_metadata
      custom_metadata_keys.map do |k|
        {
          'label' => k.to_s.delete_prefix(CUSTOM_METADATA_PREFIX),
          'value' => @record[k]
        }
      end
    end

    def build_manifest
      manifest = IIIF::Presentation::Manifest.new @seed
      sequence = IIIF::Presentation::Sequence.new
      sequence.canvases = @assets.map(&:canvas)
      manifest.sequences << sequence
      manifest
    end

    def manifest_file
      "#{CONFIG.presentation_build_dir}/#{CONFIG.batch_namespace}/#{@id}/manifest.json"
    end

    def write_presentation_json
      FileUtils.mkdir_p File.dirname(manifest_file)
      File.open(manifest_file, 'w') { |m| m.write manifest.to_json(pretty: true) }
    end

    def to_hash
      {
        'id' => @id,
        'manifest' => manifest_url,
        'thumbnail' => @assets.first.thumbnail_url
      }
    end

    def to_html_list_item
      <<~HTML
        <tr>
          <td><b>#{@id}</b></td>
          <td>#{label}</td>
          <td><a target='_blank' href='#{@assets.first.thumbnail_url}'><img style="height:100px;width:auto" class='lazy' data-original="#{@assets.first.thumbnail_url}"/></a></td>
          <td><a target='_blank' href='#{manifest_url}'><img alt='Thumbnail #{label}' src="https://upload.wikimedia.org/wikipedia/commons/e/e8/International_Image_Interoperability_Framework_logo.png" style="width:25px"/></a></td>
          <td><a target='_blank' class='is-size-7' href='#{viewpoint_url}'>#{viewpoint_url}</a></td>
        </tr>
      HTML
    end
  end
end
