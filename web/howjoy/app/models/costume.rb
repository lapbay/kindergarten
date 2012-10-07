class Costume
  include Mongoid::Document

  #has_many :users, class_name: "UserCostume", inverse_of: :costume

  field :name,              :type => String, :default => ""
  field :resource,          :type => String
  field :min,               :type => Integer, :default => 0
  field :price,             :type => Integer, :default => 0
  field :type,              :type => Integer, :default => 0

  validates_presence_of :name
  validates_presence_of :resource

  ## Trackable
  field :view_count,      :type => Integer, :default => 0

  # run 'rake db:mongoid:create_indexes' to create indexes
  #index({ name: 1 }, { unique: true, background: true })

  attr_accessible :name, :resource, :min, :price, :type
end
