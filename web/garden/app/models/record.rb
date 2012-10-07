class Record
  include Mongoid::Document

  belongs_to :task
  belongs_to :user_task
  belongs_to :profile

  field :type,              :type => Integer, :default => 0
  field :status,            :type => Integer, :default => 0
  field :desc,              :type => String,  :default => ''
  field :loc,               :type => Array,   :default => []

  field :name,              :type => String,  :default => ''
  field :md5,               :type => String,  :default => ''
  field :width,             :type => Integer, :default => 0
  field :height,            :type => Integer, :default => 0
  field :url,               :type => String,  :default => ''

  field :friends,           :type => Array,   :default => []

  # run 'rake db:mongoid:create_indexes' to create indexes
  #index({ loc: "2d" }, { min: -200, max: 200 })
  index({ loc: "2d" })
end
