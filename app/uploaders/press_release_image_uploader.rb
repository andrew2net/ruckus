class PressReleaseImageUploader < BaseUploader
  version :thumb do
    process resize_to_fill: [82, 82]
  end
end
