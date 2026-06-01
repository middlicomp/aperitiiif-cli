# frozen_string_literal: true

# TO DO COMMENT
module Aperitiiif
  # TO DO COMMENT
  module Assets
    def assets
      @assets ||= items.flat_map(&:assets)
    end

    def item_paths(dir = config.source_dir, sample: nil)
      paths = []
      Dir.new(dir).each do |entry|
        next if entry == '.' || entry == '..'

        path = File.join(dir, entry)
        next unless Utils.valid_source?(path) || File.directory?(path)
        next if Utils.item_assets_from_path(path).empty?

        paths << path
        break if sample.to_i.positive? && paths.size >= sample
      end
      paths
    end

    def item_asset_paths(path)
      Utils.item_assets_from_path(path)
    end

    def asset_paths
      @asset_paths ||= item_paths.flat_map { |path| item_asset_paths(path) }
    end
  end
end
