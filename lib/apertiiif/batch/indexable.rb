# frozen_string_literal: true

# TO DO COMMENT
module Apertiiif
  # TO DO COMMENT
  module Indexable
    def to_json(*_args)
      JSON.pretty_generate hashes
    end

    def build_html_index
      FileUtils.mkdir_p CONFIG.html_build_dir
      puts Rainbow('Creating HTML index of items...').cyan
      index_file = "#{CONFIG.html_build_dir}/index.html"
      File.open(index_file, 'w') { |f| f.write to_html }
      puts Rainbow('Done ✓').green
    end

    def build_json_index
      FileUtils.mkdir_p CONFIG.html_build_dir
      puts Rainbow('Creating JSON index of items...').cyan
      index_file = "#{CONFIG.html_build_dir}/index.json"
      File.open(index_file, 'w') { |f| f.write to_json }
      puts Rainbow('Done ✓').green
    end

    def to_html
      <<~HTML
        <!DOCTYPE html><html lang="en">
          <head>
            <meta charset="UTF-8"><meta http-equiv="X-UA-Compatible" content="ie=edge">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>apertiiif batch listing: #{CONFIG.batch_namespace}</title>
            <style>body {font-family: Sans-Serif;}</style>
          </head>
          <body>
            <h1>#{CONFIG.batch_namespace} apertiiif batch</h1>
            <p>last updated #{Apertiiif::Utils.formatted_time}</p>
            <h2>published items (#{@items.length})</h2>
            <ul>#{@items.map(&:to_html_list_item).join("\n")}</ul>
          </body>
        </html>
      HTML
    end
  end
end
