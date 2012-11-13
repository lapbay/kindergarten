class Photo
  include Mongoid::Document

  field :md5,               :type => String,  :default => ''
  field :width,             :type => Integer, :default => 0
  field :height,            :type => Integer, :default => 0
  field :url,               :type => String,  :default => ''
end
