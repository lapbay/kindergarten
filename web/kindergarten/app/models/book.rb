class Book
  include Mongoid::Document

  #has_many :profiles, autosave: true

  field :title,              :type => String, :default => ""
  field :desc,               :type => String, :default => ""
  field :path,               :type => String, :default => ""
  field :url,                :type => String, :default => ""
  field :type,               :type => Integer, :default => 0

  # run 'rake db:mongoid:create_indexes' to create indexes
  #index({ name: 1 }, { unique: true, background: true })

end
