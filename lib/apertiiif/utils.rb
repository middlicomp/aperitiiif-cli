# frozen_string_literal: true

# TO DO COMMENT
module Apertiiif
  # TO DO COMMENT
  module Utils
    def self.basename(str)
      File.basename(str).sub File.extname(str), ''
    end

    def self.rm_batch_namespace(str)
      str.sub CONFIG.batch_namespace, ''
    end

    def self.rm_service_namespace(str)
      str.sub CONFIG.service_namespace, ''
    end

    def self.formatted_time
      time = Time.now
      "#{time.month}/#{time.day}/#{time.year} at #{time.hour}:#{time.min.to_s.rjust(2, '0')}#{time.zone}"
    end
  end
end
