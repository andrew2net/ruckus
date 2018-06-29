class PhotoUploader < BaseUploader
  include PhotoVersions

  process :crop

  version :thumb do
    process resize_to_fit: [nil, 140]
  end

  def crop
    manipulate! do |img|
      width = model.photo_cropping_width.to_i
      offxet_x = model.photo_cropping_offset_x.to_i
      offxet_y = model.photo_cropping_offset_y.to_i

      img.crop "#{width}x#{width}+#{offxet_x}+#{offxet_y}" unless [width, offxet_x, offxet_y].compact.empty?
      img
    end
  end
end
