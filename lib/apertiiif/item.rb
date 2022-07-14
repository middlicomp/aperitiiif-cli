# frozen_string_literal: true

require 'iiif/presentation'

# to do
module Apertiiif
  # to do
  class Item
    attr_reader :id, :assets

    def initialize(id, assets, record = {})
      @id       = id
      @record   = record
      @assets   = assets.map { |a| Apertiiif::Asset.new a }
    end

    def manifest_url
      "#{CONFIG.presentation_api_url}/#{@id}/manifest.json"
    end

    def seed
      { '@id' => manifest_url, 'label' => @id }
    end

    def build_manifest
      manifest = IIIF::Presentation::Manifest.new seed
      sequence = IIIF::Presentation::Sequence.new
      sequence.canvases = @assets.map(&:canvas)
      manifest.sequences << sequence
      manifest
    end

    def manifest_file
      "#{CONFIG.presentation_build_dir}/#{@id}/manifest.json"
    end

    def write_presentation_json
      FileUtils.mkdir_p File.dirname(manifest_file)
      manifest = build_manifest
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
        <li>
          <b>#{@id}:</b>
          <a href='#{manifest_url}'>iiif manifest</a>,
          <a href='#{@assets.first.thumbnail_url}'>thumbnail</a>
        </li>
      HTML
    end
  end
end
