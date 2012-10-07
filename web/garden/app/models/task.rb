class Task
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :profile, class_name: "Profile", inverse_of: :owns
  has_many :profiles, class_name: "UserTask", inverse_of: :task
  has_many :records

  field :admins,            :type => Array,  :default => []

  field :name,              :type => String
  field :desc,              :type => String, :default => ""
  field :tags,              :type => Array,  :default => []
  field :categories,        :type => Array,  :default => []

  field :bonus,             :type => String,  :default => ""
  field :deadline,          :type => Time
  field :start_at,          :type => Time
  field :max,               :type => Integer, :default => 0
  field :count,             :type => Integer, :default => 1
  field :status,            :type => Integer, :default => 0

  field :place,             :type => String,  :default => ""
  field :loc,               :type => Array,   :default => []

  field :type,              :type => Integer, :default => 0
  field :subtasks,          :type => Array,   :default => []
  field :superTask,         :type => Moped::BSON::ObjectId

  ## Trackable
  field :view_count,      :type => Integer, :default => 0

  # run 'rake db:mongoid:create_indexes' to create indexes
  #index({ name: 1 }, { unique: true, background: true })
  index({ loc: "2d" })

end
