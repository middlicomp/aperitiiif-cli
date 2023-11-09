# frozen_string_literal: true

# TO DO COMMENT
module Aperitiiif
  # TO DO COMMENT
  module Records
    def records
      @records ||= records_from_file
    end

    def find_record(item_id, records = self.records)
      records.find { |record| record.id == item_id }
    end

    # has smell :reek:DuplicateMethodCall
    def records_from_file(file = config.records_file, defaults = config.records_defaults)
      return [] unless records_file_configured? file
      return [] unless records_file_exists? file

      Utils.csv_records file, defaults
    end

    def records_file_configured?(file = config.records_file)
      return true unless file.to_s.empty?

      warn 'WARNING:: No records file configured'.colorize(:yellow)
      false
    end

    def records_file_exists?(file = config.records_file)
      return true if File.file?(file)

      warn "WARNING:: Couldn't find records file #{file}".colorize(:yellow)
      false
    end

    def load_records!
      self.items = items.map do |item|
        record = find_record(item.id, records)
        item.record = record unless record.to_s.empty?
        item
      end
    end
  end
end
