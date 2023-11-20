class PdfUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  storage :aws
  def store_dir
    nil
  end
  def filename
    model.file_path 
  end
   def cover 
    manipulate! do |frame, index|
      frame if index.zero?
    end
  end
  version :nail do
    self.aws_bucket = "crystal-hair-nail"
    process :cover
    process convert: "avif"

    process :resize_and_pad => [165, nil, 'white', 'Center']
    def full_filename(for_file = model.file_name.file)
      "nail_#{for_file.sub('.pdf', '.avif')}"
    end
    def style = :thumb

    # @doc This is an overridden function from the `manipulate!` function defined in CarrierWaves library
    # @doc I removed the ability to pass in options, or a block to the function to use in processing the image.
    # @doc This seemed to be the route to go because there isn't many maintainers available on CarrierWave and the documentation is trash.
    def cover
      cache_file
      push_frames(get_frames)
    rescue ::Magick::ImageMagickError
      raise CarrierWave::ProcessingError, I18n.translate(:"errors.messages.processing_error")
    end

    private

    # @doc This will store the file available on the uploader in the cache, unless it is already cached.
    def cache_file
      cache_stored_file! unless cached?
    end

    # @doc This will utilize RMagick to create an image from an altered current_path variable
    # @doc Create a new ImageList, and store the image created as the first frame
    def get_frames
      path = "#{current_path}[0]"
      image = ::Magick::Image.read(path)
      frames = ::Magick::ImageList.new
      frames << image.first
    end

    # @doc This will persist the frames created as an ImageList into the file on the uploader, essentially replacing the original pdf with the modified pdf.
    def push_frames(frames)
      frames.write(current_path)
    end

    # @doc This will destroy the ImageList that is allocating memory.
    def destroy_image(frames)
      frames.try(:destroy!)
    end
  end

  def extension_whitelist
    %w(pdf)
  end
end
