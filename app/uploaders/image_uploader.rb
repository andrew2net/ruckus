class ImageUploader < BaseUploader

  version :thumb do
    # media on account's admin panel
    process resize_to_fill: [140, 140]
    process :get_version_dimensions
  end

  version :large_thumb do
    # media on account's page
    process resize_to_fit: [nil, 244]
    process :get_version_dimensions
  end

  def get_version_dimensions
    width, height = `identify -format "%wx%h" #{file.path}`.split(/x/)
    @geometry ||= { width: trim_param(width), height: trim_param(height) }
  end

  private

  def trim_param(param)
    param.to_s.strip.to_i
  end
end
