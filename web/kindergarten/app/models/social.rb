class Social
  include Mongoid::Document

  belongs_to  :profile
  embeds_many :friends
  field :feed_sources,       :type => Array, :default => []

  field :title,              :type => String, :default => ""
  field :count,              :type => Integer, :default => 0

  attr_accessible :friends, :feed_sources

end

