class Page < ActiveRecord::Base

  has_many :diary_dates
  has_many :places
  has_many :weathers
  has_many :activities
  has_many :people

  # Sorting dates and grouping them

  def date_means
  	self.diary_dates.group_by{ |d| d.date }.map{ |d,i| [d, i.map{|o| o.y}.inject{ |sum, el| sum + el }.to_f / i.map{ |o| o.y }.size] }
  end

  def date_index
  	self.diary_dates.group_by{ |d| d.date }.map{ |d,i| [d, i.map{|o| o.y}] }
  end

  def previous_date(pos)
  	# TODO - could use date_index here to measure stdev and define uncertainy for dates retrieved
  	i = self.date_means.select{ |i| i if i[1]<=pos }.sort_by{ |i| i[1] }.last
  	return i.nil? ? "" : i[0]
  end

  # Sorting places and grouping them

  def place_means
  	self.places.group_by{ |d| d.typed_name }.map{ |d,i| [d, i.map{|o| o.y}.inject{ |sum, el| sum + el }.to_f / i.map{ |o| o.y }.size] }
  end

  def place_index
  	self.places.group_by{ |d| d.typed_name }.map{ |d,i| [d, i.map{|o| o.y}] }
  end

  # TODO Need to only use places where at_location=true
  def previous_place(pos)
  	# TODO - could use _index here to measure stdev and define uncertainy for dates retrieved
  	i = self.place_means.select{ |i| i if i[1]<=pos }.sort_by{ |i| i[1] }.last
  	return i.nil? ? "" : i[0]
  end

  # Convenience counters

  def activities_count
  	self.activities.count
  end

  def weathers_count
  	self.weathers.count
  end

  def people_count
  	self.people.count
  end

  def places_count
  	self.places.count
  end

  def activity_count
  	self.activities.count
  end

  def weather_count
  	self.weathers.count
  end

  def person_count
  	self.people.count
  end

  def place_count
  	self.places.count
  end

  # Out summary for testing

  def summary
  	puts self.url

  	puts "People:"
  	self.people.each{|a| puts "#{a.rank} #{a.first} #{a.surname} #{a.consensus_date}" }

  	puts "Activities:"
  	self.activities.each{|a| puts "#{a.category} #{a.consensus_date}" }
  end

  attr_accessible :id, :name, :url, :group_id, :tna_id, :page_number
  
end
