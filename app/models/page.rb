class Page < ActiveRecord::Base

  has_many :diary_dates
  has_many :places
  has_many :weathers
  has_many :activities
  has_many :people

  def all_tags
    self.diary_dates + self.places + self.people + self.activities + self.weathers
  end

  def users
    self.all_tags.map{|t|t.user_id}.uniq
  end

  def clusterize(n=3)
    clustered_tags = []
    completed = []
    user_count = self.users.count
    
    tags = self.tags
  
    tags.each do |tag|
      x = tag['coords'][0].to_i
      y = tag['coords'][1].to_i
      max_y = y + n
      min_y = y - n
      max_x = x + 4 * n
      min_x = x - 4 * n
      
      set = []
      unless completed.include?(tag)
        set = tags.inject([]) do |set, t|
          tx = t['coords'][0].to_i
          ty = t['coords'][1].to_i
          x_good = tx <= max_x && tx >= min_x
          y_good = ty <= max_y && ty >= min_y
          if t['type'] == 'diaryDate'
            good = y_good
          else
            good = x_good && y_good
          end
          set << t if t['type'] == tag['type'] && good
          set
        end
    
        if set.count > 0 && completed.include?(tag) == false
          tag_count = set.size
          # Find averaged tag centre and select nearest real tag to that
          cx = set.map{|i| i['coords'][0].to_i}.inject{|sum,x| sum + x } / tag_count
          cy = set.map{|i| i['coords'][1].to_i}.inject{|sum,y| sum + y } / tag_count
          closest = set.sort_by{|i| (i['coords'][0].to_i-cx)**2 + (i['coords'][1].to_i-cy)**2}.reverse.first    
          # Add to set and record they are all done - i.e. don't duplicate process for tags in set
          clustered_tags << {"type" => tag['type'], "tag" => closest, "hit_rate" => (tag_count+1.0)/user_count}
          completed << tag
          set.each{|i| completed << i}
        elsif set.count > 0 && completed.include?(tag)==true
          #do nothing
        else  
          #Single tags still go in
          clustered_tags << {"type" => tag['type'], "tag" => tag, "hit_rate" => 1.0/user_count}
          completed << tag
        end
      end
      puts set
      puts '---------'
    end

    return clustered_tags.sort_by{|i| [i['tag']['coords'][1].to_i, i['tag']['coords'][0].to_i]}
  end
  
  def subject
    Subject.find_by_zooniverse_id( self.id )
  end
  
  def classifications
    @s = self.subject
    return @s.classifications
  end
  
  def tags
    self.classifications.map{|c|c.annotations}.flatten.select{|i|i["type"]}.sort_by{|i| [i['coords'][1], i['coords'][0]]}
  end
  
  def comments
    discussions = Discussion.where( :title => self.id ).first
    return discussions['comments'] unless discussions.nil?
    return []
  end
  
  def document_types
    types = []
    self.classifications.each do |c|
      if c.try( :annotations )
        type = c.annotations.select{|a| a["document"]}.first
        types.push type["document"] if type
      end
    end
    return types
  end

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
