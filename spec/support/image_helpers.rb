module ImageHelpers
  extend self

  def image_full_path(name)
    Rails.root.join('spec', 'fixtures', name)
  end

  def load_image(name)
    Rack::Test::UploadedFile.new(image_full_path(name), 'image/jpeg')
  end

  def open_image(name)
    File.open(image_full_path(name))
  end
end

RSpec.configure do |c|
  c.include ImageHelpers
end