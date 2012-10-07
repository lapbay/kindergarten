class UserProp
  include Mongoid::Document

  belongs_to :profile
  #belongs_to :costume, class_name: "Costume", inverse_of: :users

  #field :on,                :type => Boolean, :default => false
  field :prop_id,           :type => String

  attr_accessible :prop_id
end
