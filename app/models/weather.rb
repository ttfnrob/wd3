class Weather < ActiveRecord::Base
  belongs_to :page
  validates_uniqueness_of :user_id, :scope => [:page_id, :x, :y, :category]

  def consensus_date
  	self.page.previous_date(self.y)
  end

  attr_accessible :page_id, :type, :user_id, :x, :y, :category, :created_at
end
