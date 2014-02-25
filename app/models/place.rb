class Place < ActiveRecord::Base
  belongs_to :page
  validates_uniqueness_of :user_id, :scope => [:page_id, :x, :y, :typed_name]

  def consensus_date
  	self.page.previous_date(self.y)
  end

  attr_accessible :at_location, :geocoded_name, :lat, :lon, :page_id, :x, :y, :user_id, :typed_name, :created_at, :note
end
