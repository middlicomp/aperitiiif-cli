# frozen_string_literal: true

require 'fileutils'
require 'progress_bar'
require 'rainbow'
require 'vips'

# TO DO COMMENT
module Apertiiif
  # TO DO COMMENT
  module Api
    # TO DO COMMENT
    module Image
      def image_api
        FileUtils.mkdir_p @config.image_build_dir

        files = source_files
        bar   = ProgressBar.new files.length

        puts Rainbow('Creating TIFs...').cyan
        files.each do |f|
          tif_copy f
          bar.increment!
        end
        puts Rainbow('Done ✓').green
      end

      def tif_copy(file)
        basename  = file.sub(@config.source_dir, '').split('/').reject(&:empty?)
        newname   = "#{@config.image_build_dir}/#{basename.prepend(@config.batch_namespace).join('_')}"
        tif       = newname.sub(File.extname(newname), '.tif')

        return if File.file? tif

        image = Vips::Image.new_from_file file
        image.write_to_file tif
      end
    end
  end
end
