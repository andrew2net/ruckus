class LogoUploader < BaseUploader
  include PhotoVersions

  version :thumb do
    process resize_to_fit: [400, 140]
  end
end
