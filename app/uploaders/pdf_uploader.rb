class PdfUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  storage :aws
  def store_dir
    nil
  end
  def filename
    model.file_path 
  end
  version :nail do
    self.aws_bucket = "crystal-hair-nail"
    process :convert => 'avif'
    process :resize_and_pad => [165, 165, 'white', 'Center']
    def full_filename(for_file = model.file_name.file)
      "nail_#{for_file.sub('pdf', 'avif')}"
    end
  end
  def extension_whitelist
    %w(pdf)
  end
end
