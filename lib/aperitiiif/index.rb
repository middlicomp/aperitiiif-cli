# frozen_string_literal: true

require 'json'
require 'liquid'

# TO DO COMMENT
module Aperitiiif
  # TO DO COMMENT
  class Index
    VALID_TYPES      = %i[json html].freeze
    TEMPLATE_FILE    = "#{__dir__}/template/index.html".freeze

    attr_reader :config, :items

    def initialize(batch)
      @batch  = batch
      @config = batch.config
      @items  = batch.items
    end

    def path(type)
      "#{@config.html_build_dir}/index.#{type}"
    end

    # rubocop: disable Metrics/AbcSize
    # has smell :reek:TooManyStatements
    def write(**options)
      raise Aperitiiif::Error, "Index#write is missing required 'type:' option" unless options.key? :type
      raise Aperitiiif::Error, "Index#write 'type: #{options[:type]}' does not match available types #{VALID_TYPES}" unless VALID_TYPES.include? options[:type]

      print "Writing #{options[:type]} index...".colorize(:cyan)

      index = options[:type] == :html ? to_html : to_json
      path  = options&.[](:path) || path(options[:type])

      Aperitiiif::Utils.mkfile_p path, index

      puts "\r#{"Writing #{options[:type]} index:".colorize(:cyan)} #{'Done ✓'.colorize(:green)}    "
    end
    # rubocop: enable Metrics/AbcSize

    def to_json(items = self.items)
      JSON.pretty_generate items.map(&:to_hash)
    end

    # has smell :reek:DuplicateMethodCall
    def to_html(items = self.items, config = self.config)
      vars = {
        'items' => items.map(&:to_hash),
        'config' => config.hash,
        'iiif_collection_url' => @batch.iiif_collection_url,
        'formatted_date' => Aperitiiif::Utils.formatted_datetime
      }
      template = Liquid::Template.parse File.open(TEMPLATE_FILE).read
      template.render vars
    end
  end
end
