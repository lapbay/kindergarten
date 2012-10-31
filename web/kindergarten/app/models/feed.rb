class Feed
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :profile
  belongs_to :class_unit

  field :title,           :type => String,  :default => ""
  field :content,         :type => String,  :default => ""

  field :task,            :type => Hash,    :default => {}
  field :people,          :type => Hash,    :default => {}

  field :view_count,      :type => Integer, :default => 0

  field :type,            :type => Integer
  field :privacy,         :type => Integer, :default => 0 #0: public, 1:friends, 2:private

end
