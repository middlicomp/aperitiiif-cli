# frozen_string_literal: true

# TO DO COMMENT
module Apertiiif
  # TO DO COMMENT
  module Lintable
    def passing?
      @passing.nil? ? true : @passing
    end

    def lint
      puts Rainbow('Linting...').cyan
      warn_nil_record_items
      warn_duplicate_record_ids
      warn_duplicate_image_names
      warn_missing_labels
      warn_stray_files
      puts Rainbow('Passed ✓').green if passing?
    end

    def warn_nil_record_items
      nil_record_items = @items.select { |i| i.record.nil? }
      return if nil_record_items.empty?

      warn Rainbow("Could not find record(s) for #{nil_record_items.length} items:").orange
      nil_record_items.each { |n| puts Rainbow(Utils.rm_batch_namespace(n.id)).yellow }
      @passing = false
    end

    def warn_duplicate_record_ids
      ids     = @records.map(&:id)
      dup_ids = ids.select { |id| ids.count(id) > 1 }.uniq
      return if dup_ids.empty?

      warn Rainbow("Found #{dup_ids.length} non-unique record id value(s):").orange
      dup_ids.each { |id| puts Rainbow(id).yellow }
      @passing = false
    end

    # rubocop:disable Metrics/AbcSize
    def warn_duplicate_image_names
      files = Dir.glob("#{CONFIG.source_dir}/**/*").select { |f| File.file?(f) }
      files.map! { |f| Utils.rm_ext(Utils.rm_source_dir(f)) }
      dupes = files.select { |f| files.count(f) > 1 }.uniq
      return if dupes.empty?

      warn Rainbow("Found #{dupes.length} duplicate image name(s):").orange
      dupes.each { |d| puts Rainbow(Utils.prune_prefix_junk(d)).yellow }
      @passing = false
    end
    # rubocop:enable Metrics/AbcSize

    def warn_missing_labels
      no_label_records = @records.select { |r| r.label.to_s.empty? }
      return if no_label_records.empty?

      warn Rainbow("Found #{no_label_records.length} record(s) missing labels (strongly encouraged):").orange
      no_label_records.each { |r| puts Rainbow(r.id).yellow }
      @passing = false
    end

    # rubocop:disable Metrics/AbcSize
    def warn_stray_files
      stray_files = Dir.glob("#{CONFIG.source_dir}/**/*")
      stray_files.select! { |f| File.file?(f) && !f.end_with?(*FORMATS) }
      return if stray_files.empty?

      warn Rainbow("Found #{stray_files.length} stray file(s) with unaccepted file types:").orange
      stray_files.each { |f| puts Rainbow(f).yellow }
      puts Rainbow("(Accepted file extensions: #{FORMATS.join(', ')})").pink
      @passing = false
    end
    # rubocop:enable Metrics/AbcSize
  end
end
