class Group
  include MongoMapper::Document
  set_collection_name "war_diary_groups"
  
  key :id, ObjectId
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
      Subject.where('group.zooniverse_id' => self.zooniverse_id ).fields(:zooniverse_id, :location).sort('metadata.page_number').limit(20).each do |g|
        @pages << g
      end
    end
    @pages
  end
  
  def tags( n = 5, threshold = 1 )
    @tags = {
      'diary' => [],
      'signals' => [],
      'orders' => [],
      'report' => []
    }
    
    if @tags['diary'].empty?
      Subject.where('group.zooniverse_id' => self.zooniverse_id ).fields(:zooniverse_id, :metadata).sort('metadata.page_number').all().each do |p|
        p.document_type.keys.each do |type|
          @tags[type].push(*p.clusterize( n, threshold )) if @tags[type]
        end
      end
    end
    
    @tags
  end
  
  def timeline
    date = ''
    place = ''
    lat = ''
    long = ''
    time = ''
    datetime = ''
    
    @tags['diary'].each do |t|
      case t["type"]
      when "diaryDate"
        date = t["label"]
        datetime = Date.strptime( date, '%d %b %Y' )
        time = ''
      when "time"
        time = t["label"]
        datetime = DateTime.strptime( "#{date} #{time}", '%d %b %Y %I%M%p' ) if date != ''
      when "place"
        if t["votes"]["location"].keys == ['true']
          place = t["label"]
          trim_lat = t["votes"]["lat"].keys.reject( &:empty? )
          trim_long = t["votes"]["long"].keys.reject( &:empty? )
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
      t['lat'] = lat
      t['long'] = long
      
    end
    
    @tags['diary']
  end
  
  def completed
    completed = 100 * self.stats['complete'].to_f/self.stats['total'].to_f
    completed.round unless self.stats['total'].to_i == 0
  end
end