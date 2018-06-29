class BaseUploader < CarrierWave::Uploader::Base
  EXTENSION_WHITE_LIST = %w(jpg jpeg png)
  include CarrierWave::MiniMagick

  storage :file

  def extension_white_list
    EXTENSION_WHITE_LIST
  end

  def store_dir
    root_dir = "uploads#{'_test' if Rails.env.test?}"
    "#{root_dir}/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def default_url
    path = [model.class.to_s.underscore, mounted_as, version_name, 'default.png'].compact.join('_')
    ActionController::Base.helpers.asset_path('images/fallback/' + path)
  end
end
