class Person < ActiveRecord::Base
  belongs_to :page
  validates_uniqueness_of :user_id, :scope => [:page_id, :x, :y, :first, :surname]

  def consensus_date
  	self.page.previous_date(self.y)
  end

  def similar(n=3)
	Person.find(:all, :conditions => ["page_id LIKE ? AND user_id NOT LIKE ? AND x BETWEEN ? AND ? AND y BETWEEN ? AND ? AND surname LIKE ?", self.page_id, self.user_id, self.x-3*n, self.x+3*n, self.y-n, self.y+n, self.surname])
  end

  def type
  	"person"
  end
  
  def label
    "#{self.rank} #{self.surname}"
  end

  attr_accessible :first, :page_id, :rank, :reason, :surname, :x, :y, :user_id, :created_at
end
