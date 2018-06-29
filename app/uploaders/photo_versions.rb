module PhotoVersions
  extend ActiveSupport::Concern

  included do
    version :middle_thumb do
      # For Ask Question form
      # For photo in Dashboard
      process resize_to_fit: [nil, 100]
    end

    version :small_thumb do
      # for 'Ask Question' button
      process resize_to_fit: [nil, 40]
    end

    version :press_modal_photo_thumb do
      # for press modal
      process resize_to_fit: [98, 98]
    end
  end
end
