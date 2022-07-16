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
            <meta charset="UTF-8">
            <meta http-equiv="X-UA-Compatible" content="ie=edge">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>#{CONFIG.batch_label} | apertiiif batch listing</title>
            <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bulma@0.9.4/css/bulma.min.css">
            <link rel="stylesheet" href="https://cdn.datatables.net/1.12.1/css/jquery.dataTables.min.css">
          </head>
          <body>
            <section class="hero is-info">
              <div class="hero-body">
                <div class="container">
                  <h1 class="title">#{CONFIG.batch_label}</h1>
                  <p class="subtitle">
                    Apertiiif Batch Index
                  </p>
                  <p class="is-5 is-grey">Last updated #{Apertiiif::Utils.formatted_time}</p>
                  <p class="tags mt-5">
                    <a target='_blank' class='tag is-danger is-light' href='#{iiif_collection_url}'>iiif collection</a>
                    <a target='_blank' class='tag is-link is-light' href='index.json'>index.json</a>
                  </p>
                </div>
              </div>
            </section>
            <section class="section">
              <div class="container">
                <h2 class="is-size-4 mb-3">Items (#{@items.length})</h3>
                <table id="table" class="table display is-hoverable is-striped is-bordered">
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
                    #{@items.map(&:to_html_list_item).join("\n")}
                  </tbody>
                </table>
              </div>
            </section>
            <script src="https://code.jquery.com/jquery-3.5.1.js"></script>
            <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.lazyload/1.9.1/jquery.lazyload.min.js"></script>
            <script src="https://cdn.datatables.net/1.12.1/js/jquery.dataTables.min.js"></script>
            <script>
              $(document).ready(function () {
                $('#table').DataTable( {
                  drawCallback: function(){
                    $("img.lazy").lazyload();
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
