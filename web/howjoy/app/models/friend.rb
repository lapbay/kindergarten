class Friend
  include Mongoid::Document

  embedded_in :social

  field :relation,          :type => Integer, :default => 0
  field :profile_id,        :type => Moped::BSON::ObjectId
  field :_id,               :type => Moped::BSON::ObjectId, :default => :profile_id
  field :name,              :type => String,  :default => ''
  field :url,               :type => String,  :default => ''

  attr_accessible :relation, :profile_id, :name, :url

end
