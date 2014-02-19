class Person < ActiveRecord::Base
  belongs_to :page
  validates_uniqueness_of :user_id, :scope => [:page_id, :x, :y, :first, :surname]

  def consensus_date
  	self.page.previous_date(self.y)
  end

  attr_accessible :first, :page_id, :rank, :reason, :surname, :x, :y, :user_id
end
