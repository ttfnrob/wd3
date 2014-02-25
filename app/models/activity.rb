class Activity < ActiveRecord::Base
  belongs_to :page
  validates_uniqueness_of :user_id, :scope => [:page_id, :x, :y, :category]

  def consensus_date
  	self.page.previous_date(self.y)
  end

  def similar(n=3)
	Activity.find(:all, :conditions => ["page_id LIKE ? AND user_id NOT LIKE ? AND x BETWEEN ? AND ? AND y BETWEEN ? AND ? AND category LIKE ?", self.page_id, self.user_id, self.x-n, self.x+n, self.y-n, self.y+n, self.category])
  end

  attr_accessible :page_id, :type, :user_id, :x, :y, :category, :created_at
end
