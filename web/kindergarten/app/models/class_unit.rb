class ClassUnit
  include Mongoid::Document

  has_many :profiles, autosave: true

  field :name,              :type => String, :default => ""
  field :grade,             :type => Integer, :default => 0

  validates_presence_of :name
  validates_presence_of :grade

  # run 'rake db:mongoid:create_indexes' to create indexes
  #index({ name: 1 }, { unique: true, background: true })

  attr_accessible :name, :grade
end
