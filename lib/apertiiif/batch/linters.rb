# frozen_string_literal: true

# TO DO COMMENT
module Apertiiif
  # TO DO COMMENT
  module Linters
    def linters
      @linters ||= [
        method(:warn_nil_record_items),
        method(:warn_duplicate_record_ids),
        method(:warn_duplicate_image_names),
        method(:warn_missing_labels),
        method(:warn_stray_files)
      ]
    end

    def lint
      puts Rainbow('Linting...').cyan
      puts Rainbow('Passed ✓').green unless report_failures.any?
    end

    def report_failures
      linters.map(&:call)
    end

    # has smell :reek:TooManyStatements
    def warn_nil_record_items
      nil_record_items = items.select { |item| item.record.blank? }
      return false if nil_record_items.empty?

      warn Rainbow("Could not find record(s) for #{nil_record_items.length} items:").orange
      nil_record_items.each { |item| puts Rainbow(Utils.rm_batch_namespace(item.id)).yellow }
      true
    end

    # has smell :reek:TooManyStatements
    def warn_duplicate_record_ids
      ids     = records.map(&:id)
      dup_ids = ids.select { |id| ids.count(id) > 1 }.uniq
      return false if dup_ids.empty?

      warn Rainbow("Found #{dup_ids.length} non-unique record id value(s):").orange
      dup_ids.each { |id| puts Rainbow(id).yellow }
      true
    end

    # has smell :reek:DuplicateMethodCall
    # has smell :reek:TooManyStatements
    # rubocop: disable Metrics/AbcSize
    def warn_duplicate_image_names
      files = Dir.glob("#{config.source_dir}/**/*").select { |file| File.file? file }
      files.map! { |file| Utils.rm_ext file.sub(config.source_dir, '') }
      duplicate_names = files.select { |file| files.count(file) > 1 }.uniq
      return false if duplicate_names.empty?

      warn Rainbow("Found #{duplicate_names.length} duplicate image name(s):").orange
      duplicate_names.each { |name| puts Rainbow(Utils.prune_prefix_junk(name)).yellow }
      true
    end
    # rubocop: enable Metrics/AbcSize

    # has smell :reek:TooManyStatements
    def warn_missing_labels
      no_label_records = records.select { |record| record.label.to_s.empty? }
      return false if no_label_records.empty?

      warn Rainbow("Found #{no_label_records.length} record(s) missing labels (strongly encouraged):").orange
      no_label_records.each { |record| puts Rainbow(record.id).yellow }
      true
    end

    # has smell :reek:TooManyStatements
    # rubocop:disable Metrics/AbcSize
    def warn_stray_files
      stray_files = Dir.glob("#{config.source_dir}/**/*")
      stray_files.select! { |file| File.file?(file) && !file.end_with?(*ALLOWED_SRC_FORMATS) }
      return false if stray_files.empty?

      warn Rainbow("Found #{stray_files.length} stray file(s) with unaccepted file types:").orange
      stray_files.each { |file| puts Rainbow(file).yellow }
      puts Rainbow("(Accepted file extensions: #{ALLOWED_SRC_FORMATS.join(', ')})").pink
      true
    end
    # rubocop:enable Metrics/AbcSize
  end
end
