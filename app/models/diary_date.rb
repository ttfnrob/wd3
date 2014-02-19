class DiaryDate < ActiveRecord::Base
  attr_accessible :date, :page_id, :user_id, :x, :y
  validates_uniqueness_of :user_id, :scope => [:page_id, :x, :y, :date]

  belongs_to :page
end
