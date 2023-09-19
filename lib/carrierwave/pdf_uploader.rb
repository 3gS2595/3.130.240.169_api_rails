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
    process resize_to_fit: [165,165]
  end
  def extension_whitelist
    %w(pdf)
  end
end
