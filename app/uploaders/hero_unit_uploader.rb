class HeroUnitUploader < BaseUploader
  version :thumb do
    process resize_to_fill: [140, 140]
  end

  version :large_thumb do
    process resize_to_fit: [400, 400]
  end
end
