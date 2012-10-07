class FriendRequest
  include Mongoid::Document

  embedded_in :profile
  #belongs_to :profile, class_name: "Profile", inverse_of: :requests

  field :status,            :type => Integer, :default => 0
  field :from_id,           :type => Moped::BSON::ObjectId

  attr_accessible :status, :from_id
end
