# frozen_string_literal: true

# TO DO COMMENT
module Aperitiiif
  # TO DO COMMENT
  module CLI
    # TO DO COMMENT
    class SubCommandBase < Thor
      def self.banner(command, _namespace, _subcommand)
        "#{basename} #{subcommand_prefix} #{command.usage}"
      end

      def self.subcommand_prefix
        str = name.gsub(/.*::/, '')
        str.gsub!(/^[A-Z]/) { |match| match[0].downcase }
        str.gsub!(/[A-Z]/) { |match| "-#{match[0].downcase}" }
        str
      end
    end

    # TO DO COMMENT
    class Batch < SubCommandBase
      desc 'build', 'build batch resources'

      option :config, type: :string, default: ''
      option :lint,   type: :boolean
      option :reset,  type: :boolean
      option :sample, type: :numeric, default: 0, desc: 'Limit the batch to the first N items for testing'
      option :image_format, type: :string, default: '', desc: 'Output image format: tif or jpg'

      # has smells :reek:FeatureEnvy, :reek:TooManyStatements
      # rubocop:disable Metrics/AbcSize
      def build
        batch = Aperitiiif::Batch.new
        batch.load_config_file(options[:config]) unless options[:config].to_s.empty?
        if options[:image_format].to_s != ''
          batch.config.hash['image_output_format'] = options[:image_format].to_s.downcase
          batch.config.validate
        end
        batch.sample = options[:sample].to_i if options[:sample].to_i.positive?
        batch.reset if options[:reset]
        batch.lint  if options[:lint]

        batch.write_target_assets
        batch.write_presentation_json
        index = Aperitiiif::Index.new batch
        index.write type: :html
        index.write type: :json
      end
      # rubocop:enable Metrics/AbcSize

      desc 'reset', 'reset the batch'
      def reset
        batch = Aperitiiif::Batch.new
        batch.reset
      end

      desc 'lint', 'lint the batch'
      def lint
        batch = Aperitiiif::Batch.new
        batch.lint
      end
    end

    # TO DO COMMENT
    class Main < Thor
      map %w[--version -v] => :__print_version
      desc '--version, -v', 'print the version'
      def __print_version
        puts Aperitiiif::VERSION
      end

      desc 'batch SUBCOMMANDS', 'batch subcommands'
      subcommand 'batch', Batch
    end
  end
end
