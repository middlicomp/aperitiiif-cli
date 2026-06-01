# frozen_string_literal: true

require 'json'

module Aperitiiif
  module Checkpoints
    def checkpoints_dir
      @checkpoints_dir ||= "#{config.build_dir}/.checkpoint/items"
    end

    def item_checkpoint_file(item_id)
      "#{checkpoints_dir}/#{item_id}.json"
    end

    def load_item_checkpoint(item_id)
      return nil unless File.file?(item_checkpoint_file(item_id))

      JSON.parse File.read(item_checkpoint_file(item_id))
    rescue JSON::ParserError
      nil
    end
  end
end
