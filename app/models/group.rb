class Group
  include MongoMapper::Document
  set_collection_name "war_diary_groups"
  
  key :zooniverse_id, String
  key :stats, Hash
  key :metadata, Hash
  
  def start_date
    Time.at self.metadata["start_date"]
  end
  
  def end_date
    Time.at self.metadata["end_date"]
  end
  
  def pages
    @pages ||= []
    if @pages.empty?
      Subject.fields(:zooniverse_id, :location).sort('metadata.page_number').limit(20).find_each('group.zooniverse_id' => self.zooniverse_id ) do |g|
        @pages << g
      end
    end
    @pages
  end
  
  def tags( n = 5, threshold = 1 )
    @tags ||= []
    
    Subject.fields(:zooniverse_id, :metadata, :group).sort('metadata.page_number').find_each('group.zooniverse_id' => self.zooniverse_id ) do |p|
      @tags.push(*p.clusterize( n ))
    end

    @tags = @tags.select{|tag| tag["count"] >= threshold || (tag["page_type"] == "report" && tag["type"] == "person")}
  end
  
  def timeline
    date = ''
    place = ''
    lat = ''
    long = ''
    time = ''
    datetime = ''
    
    @tags.each do |t|
      if t["page_type"] == "diary"
        case t["type"]
        when "diaryDate"
          date = t["label"]
          begin
            datetime = Date.strptime( date, '%d %b %Y' )
          rescue
            datetime = ''
          end
          time = ''
        when "time"
          time = t["label"]
          begin
            datetime = DateTime.strptime( "#{date} #{time}", '%d %b %Y %I%M%p' ) if date != ''
          rescue
            datetime = ''
          end
        when "place"
          if t["votes"]["location"] == ['true']
            place = t["label"]
            trim_lat = t["votes"]["lat"].reject( &:empty? )
            trim_long = t["votes"]["long"].reject( &:empty? )
            if trim_lat.length == 1
              lat = trim_lat.join ','
              long = trim_long.join ','
            else
              lat = ''
              long = ''
            end
          end
        end
        
        t['datetime'] = datetime
        t['date'] = date
        t['time'] = time
        t['place'] = place
        t['coords'] = [long.to_f, lat.to_f]
        
      end
      
      Timeline.new( t.attributes ).save() if self.state = 'complete'
    end
    
    @tags
  end
  
  def completed
    completed = 100 * self.stats['complete'].to_f/self.stats['total'].to_f
    completed.round unless self.stats['total'].to_i == 0
  end
end