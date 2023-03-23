class AvatarUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file

  version :thumb do
    process resize_to_fill: [300, 300]
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def default_url(*)
    path = 'defaults/default-user.png'
    ActionController::Base.helpers.asset_path(path)
  end

  def extension_allowlist
    %w[jpg jpeg gif png]
  end
end
