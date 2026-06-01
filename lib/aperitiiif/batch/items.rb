# frozen_string_literal: true

require 'aperitiiif/item'

# TO DO COMMENT
module Aperitiiif
  # TO DO COMMENT
  module Items
    def items
      @items ||= items_from_paths
    end

    def items=(items)
      @items = items
    end

    def items_from_paths(paths = item_paths(sample: sample))
      puts "Found #{paths.size} items in source directory #{config.source_dir}".colorize(:cyan)

      paths.map do |path|
        id = Utils.parent_id(path, config.source_dir)
        Item.new id, item_asset_paths(path), config, checkpoint: load_item_checkpoint(id)
      end
    end
  end
end
