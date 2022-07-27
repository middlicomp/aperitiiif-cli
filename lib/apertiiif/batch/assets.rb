# frozen_string_literal: true

# TO DO COMMENT
module Apertiiif
  # TO DO COMMENT
  module Assets
    def assets
      @assets ||= map_to_assets
    end

    def child_assets(path)
      return [path] if Utils.valid_source?(path)
      return [] unless File.directory? path

      Dir.glob("#{path}/*").select { |sub| Utils.valid_source? sub }
    end

    # has smell :reek:NestedIterators
    def map_to_assets(mymap = asset_map)
      mymap.flat_map { |id, vals| vals.map { |val| Asset.new id, val, config } }
    end

    def asset_map(dir = config.source_dir)
      map = {}
      Dir["#{dir}/*"].each do |path|
        parent_id       = Utils.parent_id(path, dir)
        children        = child_assets path
        map[parent_id]  = children unless children.empty?
      end
      map
    end
  end
end
