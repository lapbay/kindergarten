class UserCostume
  include Mongoid::Document

  embedded_in :profile
  #belongs_to :costume, class_name: "Costume", inverse_of: :users

  #field :on,                :type => Boolean, :default => false
  field :costume_id,           :type => String

  attr_accessible :costume_id
end
