class UserTask
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :task, class_name: "Task", inverse_of: :profiles
  belongs_to :profile, class_name: "Profile", inverse_of: :tasks
  has_many :records, autosave: true

  field :role,                :type => Integer, :default => 0
  field :status,              :type => Integer, :default => 0
  field :step,                :type => Integer, :default => 0
  field :type,                :type => Integer, :default => 0
  field :subtasks,            :type => Array,   :default => []

  field :name,                :type => String,  :default => ''
  field :start_at,            :type => Time
  field :place,               :type => String,  :default => ''

end
