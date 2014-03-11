# -*- encoding : utf-8 -*-
class TelasiUploader < CarrierWave::Uploader::Base
  storage :file

  def store_dir
    def singular_name
      if model.respond_to?(:model_name) then model.model_name.singular_route_key
      else model.class.table_name.singularize end
    end
    "uploads/#{singular_name}/#{model.id}"
  end

  def exists?
    file and file.exists?
  end

  def filename; self.url.split('/').last rescue nil end
end
