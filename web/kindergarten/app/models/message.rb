class Message
  include Mongoid::Document
  include Mongoid::Timestamps

  #belongs_to :profile
  #embeds_one :friend
  field :content,         :type => String, :default => ""
  field :reply,           :type => String

  field :from_id,         :type => String
  field :to_id,           :type => String
  field :from,            :type => Hash,  :default => {}
  field :to,              :type => Hash,  :default => {}

  field :type,            :type => Integer, :default => 0
  #field :privacy,         :type => Integer, :default => 0 #0: private, 1:friends, 2:public

end
