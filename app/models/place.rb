class Place < ActiveRecord::Base
  belongs_to :page
  validates_uniqueness_of :user_id, :scope => [:page_id, :x, :y, :typed_name]

  def consensus_date
  	self.page.previous_date(self.y)
  end

  def similar(n=3)
	Place.find(:all, :conditions => ["page_id LIKE ? AND user_id NOT LIKE ? AND x BETWEEN ? AND ? AND y BETWEEN ? AND ? AND typed_name LIKE ?", self.page_id, self.user_id, self.x-4*n, self.x+4*n, self.y-n, self.y+n, self.typed_name])
  end

  def type
  	"place"
  end
  
  def label
    self.typed_name
  end

  attr_accessible :at_location, :geocoded_name, :lat, :lon, :page_id, :x, :y, :user_id, :typed_name, :created_at, :note
end
