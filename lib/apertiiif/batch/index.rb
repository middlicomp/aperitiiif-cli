# frozen_string_literal: true

require 'json'

# TO DO COMMENT
module Apertiiif
  # TO DO COMMENT
  module Index
    BULMA_CSS_URL       = 'https://cdn.jsdelivr.net/npm/bulma@0.9.4/css/bulma.min.css'
    DATATABLES_CSS_URL  = 'https://cdn.datatables.net/1.12.1/css/jquery.dataTables.min.css'
    JQUERY_JS_URL       = 'https://code.jquery.com/jquery-3.5.1.js'
    LAZYLOAD_JS_URL     = 'https://cdnjs.cloudflare.com/ajax/libs/jquery.lazyload/1.9.1/jquery.lazyload.min.js'
    DATATABLES_JS_URL   = 'https://cdn.datatables.net/1.12.1/js/jquery.dataTables.min.js'

    def to_json(items = self.items)
      JSON.pretty_generate items.map(&:to_hash)
    end

    def write_html_index(_items = items)
      index_file = "#{@config.html_build_dir}/index.html"
      FileUtils.mkdir_p File.dirname(index_file)
      print Rainbow('Writing HTML index of items...').cyan
      File.open(index_file, 'w') { |file| file.write to_html }
      print("\r#{Rainbow('Writing HTML index:').cyan} #{Rainbow('Done ✓').green}        \n")
    end

    def write_json_index(items = self.items)
      index_file = "#{@config.html_build_dir}/index.json"
      FileUtils.mkdir_p File.dirname(index_file)
      print Rainbow('Creating JSON index of items...').cyan

      File.open(index_file, 'w') { |file| file.write to_json(items) }
      print("\r#{Rainbow('Writing JSON index:').cyan} #{Rainbow('Done ✓').green}        \n")
    end

    # has smell :reek:DuplicateMethodCall
    def to_html(items = self.items)
      <<~HTML
        <!DOCTYPE html><html lang='en'>
          <head>
            <meta charset='UTF-8'>
            <meta http-equiv='X-UA-Compatible' content='ie=edge'>
            <meta name='viewport' content='width=device-width, initial-scale=1.0'>
            <title>#{config.label} | apertiiif batch listing</title>
            <link rel='stylesheet' href='#{BULMA_CSS_URL}'>
            <link rel='stylesheet' href='#{DATATABLES_CSS_URL}'>
          </head>
          <body>
            <section class='hero is-info'>
              <div class='hero-body'>
                <div class='container'>
                  <h1 class='title'>#{config.label}</h1>
                  <p class='subtitle'>
                    Apertiiif Batch Index
                  </p>
                  <p class='is-5 is-grey'>Last updated #{Apertiiif::Utils.formatted_datetime}</p>
                  <p class='tags mt-5'>
                    <a target='_blank' class='tag is-danger is-light' href='#{iiif_collection_url}'>iiif collection</a>
                    <a target='_blank' class='tag is-link is-light' href='index.json'>index.json</a>
                  </p>
                </div>
              </div>
            </section>
            <section class='section'>
              <div class='container'>
                <h2 class='is-size-4 mb-3'>Items (#{items.length})</h2>
                <div class='table-container'>
                  <table id='table' class='table display is-hoverable is-striped is-bordered'>
                    <thead>
                      <tr>
                        <td>item id</td>
                        <td>label</td>
                        <td>thumbnnail</td>
                        <td>iiif manifest</td>
                        <td>view in viewpoint</td>
                      </tr>
                    </thead>
                    <tbody>
                      #{items.map(&:to_html_list_item).join("\n")}
                    </tbody>
                  </table>
                </table>
              </div>
            </section>
            <script src='#{JQUERY_JS_URL}'></script>
            <script src='#{LAZYLOAD_JS_URL}'></script>
            <script src='#{DATATABLES_JS_URL}'></script>
            <script>
              $(document).ready(function () {
                $('#table').DataTable( {
                  drawCallback: function(){
                    $('img.lazy').lazyload();
                  }
                });
              });
            </script>
          </body>
        </html>
      HTML
    end
  end
end
