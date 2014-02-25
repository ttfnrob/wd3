class DiaryDate < ActiveRecord::Base
  attr_accessible :date, :page_id, :user_id, :x, :y, :created_at, :note
  validates_uniqueness_of :user_id, :scope => [:page_id, :x, :y, :date]

  belongs_to :page

  def similar(n=3)
	DiaryDate.find(:all, :conditions => ["page_id LIKE ? AND user_id NOT LIKE ? AND x BETWEEN ? AND ? AND y BETWEEN ? AND ? AND date LIKE ?", self.page_id, self.user_id, self.x-n, self.x+n, self.y-n, self.y+n, self.date])
  end
end
