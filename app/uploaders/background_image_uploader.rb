class BackgroundImageUploader < BaseUploader
  process :crop

  version :thumb do
    process resize_to_fill: [140, 140]
  end

  def crop
    manipulate! do |img|
      width = model.background_image_cropping_width.to_i
      height =  model.background_image_cropping_height.to_i
      offxet_x = model.background_image_cropping_offset_x.to_i
      offxet_y = model.background_image_cropping_offset_y.to_i

      img.crop "#{width}x#{height}+#{offxet_x}+#{offxet_y}" unless [width, height, offxet_x, offxet_y].compact.empty?
      img
    end
  end
end
