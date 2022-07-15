# frozen_string_literal: true

# TO DO COMMENT
module Apertiiif
  # TO DO COMMENT
  module Utils
    def self.basename(str)
      rm_ext File.basename(str)
    end

    def self.rm_ext(str)
      str.sub File.extname(str), ''
    end

    def self.prune_prefix_junk(str)
      str.sub(/^(_|\W)/, '')
    end

    def self.rm_batch_namespace(str)
      prune_prefix_junk(str.sub(CONFIG.batch_namespace, ''))
    end

    def self.rm_service_namespace(str)
      prune_prefix_junk(str.sub(CONFIG.service_namespace, ''))
    end

    def self.formatted_time
      time = Time.now
      "#{time.month}/#{time.day}/#{time.year} at #{time.hour}:#{time.min.to_s.rjust(2, '0')}#{time.zone}"
    end

    def self.rm_source_dir(str)
      str.sub(CONFIG.source_dir, '')
    end
  end
end
