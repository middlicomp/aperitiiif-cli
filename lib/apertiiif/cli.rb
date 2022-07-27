# frozen_string_literal: true

# TO DO COMMENT
module Apertiiif
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

      # has smells :reek:FeatureEnvy, :reek:TooManyStatements
      # rubocop:disable Metrics/AbcSize
      def build
        batch = Apertiiif::Batch.new
        batch.load_config_file(options[:config]) if options[:config].present?
        batch.reset if options[:reset]
        batch.lint  if options[:lint]

        batch.write_target_assets
        batch.write_presentation_json
        batch.write_html_index
        batch.write_json_index
      end
      # rubocop:enable Metrics/AbcSize

      desc 'reset', 'reset the batch'
      def reset
        batch = Apertiiif::Batch.new
        batch.reset
      end

      desc 'lint', 'lint the batch'
      def lint
        batch = Apertiiif::Batch.new
        batch.lint
      end
    end

    # TO DO COMMENT
    class Main < Thor
      map %w[--version -v] => :__print_version
      desc '--version, -v', 'print the version'
      def __print_version
        puts Apertiiif::VERSION
      end

      desc 'batch SUBCOMMANDS', 'batch subcommands'
      subcommand 'batch', Batch
    end
  end
end
