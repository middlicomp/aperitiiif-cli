# frozen_string_literal: true

require 'aperitiiif/item'

# TO DO COMMENT
module Aperitiiif
  # TO DO COMMENT
  module Items
    def items
      @items ||= items_from_assets
    end

    def items=(items)
      @items = items
    end

    def items_from_assets(assets = self.assets)
      grouped = assets.group_by(&:parent_id)
      grouped.flat_map do |id, grouped_assets|
        Item.new id, grouped_assets, config
      end
    end
  end
end
