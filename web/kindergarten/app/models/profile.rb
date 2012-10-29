class Profile
  include Mongoid::Document
  #include Mongoid::Timestamps

  belongs_to  :user
  belongs_to  :class_unit
  embeds_many :requests, class_name: "FriendRequest"
  has_one     :social, autosave: true
  has_many    :feeds, autosave: true
  has_many    :notifications, autosave: true
  has_many    :records, autosave: true
  has_many    :owns, class_name: "Task", inverse_of: :profile, autosave: true
  has_many    :tasks, class_name: "UserTask", inverse_of: :profile, autosave: true

  field :name,              :type => String, :default => ""
  field :avatar,            :type => String, :default => ""
  field :start_at,          :type => Time

  validates_presence_of :name
  validates_presence_of :start_at

  field :permission,        :type => Integer, :default => 0
  field :level,             :type => Integer, :default => 1
  field :rank,              :type => Integer, :default => 0

  field :tasks_t,           :type => Integer, :default => 0     #total tasks
  field :tasks_s,           :type => Integer, :default => 0     #tasks successfully done
  field :tasks_f,           :type => Integer, :default => 0     #failed tasks
  field :tasks_r,           :type => Float,   :default => 0.0   #success rate

  ## Trackable
  field :view_count,        :type => Integer, :default => 0

  # run 'rake db:mongoid:create_indexes' to create indexes
  #index({ name: 1 }, { unique: true, background: true })

  #attr_accessible :name, :start_at

end
