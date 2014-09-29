class Subject
  include MongoMapper::Document
  set_collection_name "war_diary_subjects"
 
  key :workflow_ids, Array
  key :state, String
  key :location, Hash
  key :classification_count, Integer

  key :metadata, Hash
  key :size, String
  key :zooniverse_id, String
  key :group, Hash
  
  LEV_THRESHOLD = 4
  STATUSES = ['active', 'inactive', 'complete', 'disabled']
  
  def self.counts
    c = {}
    for status in STATUSES
      c[status] = Subject.count(:state => status)
    end
    c
  end
  
  def classifications
    @classifications ||= []
    if @classifications.empty?
      Classification.where(:subject_ids => [self.id]).each do |c|
        @classifications << c
      end
    end
    @classifications
  end
  
  def image
    self.location["standard"]
  end

  def group_name
    self.group["name"]
  end

  def group_id
    self.group["zooniverse_id"]
  end

  def tna_id
    self.metadata["tna_id"]
  end

  def page_number
    self.metadata["page_number"]
  end
  
  def timeline( tags=[] )
    page_type = self.document_type.keys.join(', ')
    return tags unless page_type == 'diary'
    
    date = ''
    place = ''
    lat = ''
    long = ''
    time = ''
    datetime = ''
    
    tags.each do |t|
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
      t['lat'] = lat
      t['long'] = long
      
    end
    
    tags
  end
  
  def clusterize(n=3)
    clusters = []
    order = 0
    
    Tag.find_each( :subject_id => self.id ) do |t|
      clusters << t
    end
    if clusters.empty?
      self.build_clusters( n ).each do |tag|
        tag['votes'].each do |k,v|
          tag['votes'][k] = v.keys
        end
        order += 1
        t = Tag.new tag
        t['subject_id'] = self.id
        t['page_order'] = order
        t.save if self.state == 'complete'
        clusters << t
      end
      puts self.page_number, self.state
    end
    clusters
  end
  
  def build_clusters(n = 3)
    clustered_tags = []
    completed = []
    user_count = self.users.count
  
    self.cached_tags.each do |tag|
      
      unless tag['completed']
        set = self.build_set(tag, n)
        
        tag_count = set.size
        # Find averaged tag centre and select nearest real tag to that
        cx = set.map{|i| i['coords'][0].to_i}.inject{|sum,x| sum + x } / tag_count
        cy = set.map{|i| i['coords'][1].to_i}.inject{|sum,y| sum + y } / tag_count
        closest = set.sort_by{|i| (i['coords'][0].to_i-cx)**2 + (i['coords'][1].to_i-cy)**2}.reverse.first
        votes = {}
        case tag['type']
        when 'diaryDate'
          votes = self.gather_votes(['day', 'month', 'year'], set)
        when 'place'
          votes = self.gather_votes(['place', 'location', 'name', 'lat', 'long', 'id'], set)
        when 'person'
          votes = self.gather_votes(['first', 'surname', 'rank', 'number', 'reason', 'unit'], set)
        when 'unit'
          votes = self.gather_votes(['name', 'context'], set)
        end
        
        clustered_tags << {"group" => self.group_id, "page" => self.zooniverse_id, "page_number" => self.page_number, "page_type" => self.document_type.keys.join(', '), "type" => tag['type'], "x" => cx, "y" => cy, "label" => closest["label"], "compare" => closest["compare"], "count" => tag_count, "hit_rate" => tag_count.to_f/user_count.to_f, "votes" => votes}
      end
    end
    
    if n == 0
      cleaned_tags = clustered_tags
    else
      cleaned_tags = self.merge_adjacent_tags( clustered_tags )
    end
    
    # decide on voted fields
    cleaned_tags.each do |t|
      t['votes'].each do |k,v|
        max_vote = v.values.max
        t['votes'][k] = v.select { |k, vote| vote == max_vote }
      end
      case t["type"]
      when 'diaryDate'
        t['label'] = "#{t['votes']['day'].keys.join(',')} #{t['votes']['month'].keys.join(',')} #{t['votes']['year'].keys.join(', ')}"
      when 'place'
        t['label'] = t['votes']['place'].keys.join(', ')
      when 'person'
        t['label'] = "#{t['votes']['rank'].keys.join(',')} #{t['votes']['first'].keys.join(',')} #{t['votes']['surname'].keys.join(', ')}"
      when 'unit'
        t['label'] = t['votes']['name'].keys.join(', ')
      end
    end
    
    cleaned_tags
  end
  
  def build_set(tag, n)
    # all other tags of same type which are not completed yet.
    comparison = self.tags_by_type( tag[ 'type' ] ).reject{|t| t['completed'] || t == tag }
    
    x = tag['coords'][0].to_i
    y = tag['coords'][1].to_i
    label = tag['label'] || ''
    max_y = y + n
    min_y = y - n
    max_x = x + 4 * n
    min_x = x - 4 * n
    
    set = []
    set << tag
    
    comparison.inject(set) do |set, t|
      tx = t['coords'][0].to_i
      ty = t['coords'][1].to_i
      tlabel = t['label'] || ''
      x_good = tx <= max_x && tx >= min_x
      y_good = ty <= max_y && ty >= min_y
    
      case tag['type']
      when 'diaryDate'
        t_date = tlabel.split(' ')
        tag_date = label.split(' ')
        good = t_date[0] == tag_date[0]
      when 'place', 'person', 'unit'
        good = Levenshtein.distance(t['compare'], tag['compare']) < LEV_THRESHOLD
      else
        good = t['compare'] == tag['compare']
      end
      if t['type'] == 'diaryDate'
        good = y_good && good
      else
        good = x_good && y_good && good
      end
      set << t if good
      t['completed'] = true if good
      set
    end
    
    set
  end
  
  def merge_adjacent_tags(clustered_tags)
    cleaned_tags = []
    initial_tag = {"type" => '', "compare" => "", "count" => 0, "hit_rate" => 0}
    clustered_tags.sort_by{|i| [i['y'], i['x']]}.inject(initial_tag) do |last_tag, tag|
      case tag["type"]
      when 'person', 'place', 'unit'
        match = Levenshtein.distance(tag['compare'], last_tag['compare']) < LEV_THRESHOLD
      else
        match = tag["compare"] == last_tag["compare"]
      end
      if tag["type"] == last_tag["type"] && match
        last_tag["count"] += tag["count"]
        votes = last_tag["votes"]
        votes.each do |k,v|
          last_tag['votes'][k] = v.merge( tag['votes'][k] ){ |key, old, new| old + new }
        end
      else
        cleaned_tags << tag
      end
      cleaned_tags.last
    end
    cleaned_tags
  end
  
  def gather_votes(fields, set)
    votes = {}
    set.each do |t|
      fields.each do |f|
        votes[f] ||= {}
        label = t['note'][f]
        # label = 'none' if label == ''
        votes[ f ][ label ] ||= 0
        votes[ f ][ label ] += 1
      end
    end
    votes
  end
 
  def tags
    tags = self.classifications.map{|c|c.annotations}.flatten.select{|i|i["note"]}.sort_by{|i| [i['coords'][1], i['coords'][0]]}
    
    tags.each do |tag|
      note = tag['note']
      case tag['type']
      when 'diaryDate'
        tag['coords'][0] = 6
        tag['label'] = note.to_s
        date = tag['label'].split ' '
        tag['note'] = {
          "day" => date[0],
          "month" => date[1],
          "year" => date[2],
        }
      when 'person'
        note['first'] = note['first'].gsub(/[\. ]+/, ' ').strip if note['first']
        tag['label'] = "#{note['first']} #{note['surname']}"
      when 'place'
        tag['label'] = "#{note['place']}"
      when 'reference'
        tag['label'] = note['reference']
      when 'unit'
        tag['label'] = note['name']
      when 'casualties'
        labels = note.reject{|k,v| v.to_i == 0}.map{|k,v| "#{k}: #{v}"}
        tag['label'] = labels.empty? ? 'casualties: 0' : labels.join(', ')
      when 'strength'
        labels = note.reject{|k,v| v.to_i == 0}.map{|k,v| "#{k}: #{v}"}
        tag['label'] = labels.empty? ? 'strength: 0' : labels.join(', ')
      when 'gridRef'
        labels = note.reject{|k,v| v == ''}.values
        tag['label'] = labels.empty? ? '' : labels.join(' ')
      when 'mapRef'
        labels = note.reject{|k,v| v == ''}.map{|k,v| "#{k}: #{v}"}
        tag['label'] = labels.empty? ? '' : labels.join(', ')
      else
        tag['label'] = note.to_s
      end
      tag['label'].strip!
      tag['compare'] = tag['label'].upcase.gsub(/[^A-Z0-9]/, '')
      tag['completed'] = false
    end
    
    tags.reject{|t| t['coords'][0].to_i < 0 || t['coords'][1].to_i < 0 || t['coords'][0].to_i > 100 || t['coords'][1].to_i > 100 }.sort_by{|i| [i['coords'][1].to_i, i['coords'][0].to_i]}
  end
  
  def cached_tags
    @tags ||= []
    if @tags.empty?
      self.tags.each do |t|
        @tags << t
      end
    end
    
    @tags
  end
  
  def tags_by_type( type )
    @tags_by_type ||= {}
    @tags_by_type[ type ] ||= self.cached_tags.select{ |t| t['type'] == type }
    @tags_by_type[ type ]
  end
  
  def comments
    # discussions = Discussion.where( :title => self.zooniverse_id ).first
    resp = Net::HTTP.get_response(URI.parse("https://api.zooniverse.org/projects/war_diary/talk/subjects/#{self.zooniverse_id}"))
    data = resp.body

    discussions = JSON.parse(data)["discussion"]
    return discussions['comments'] unless discussions.nil?
    return []
  end
  
  def document_types
    @document_types ||= self.classifications.map{|c| c.annotations.select{|a| a['document']}}.flatten
  end
  
  def document_type
    votes = {}
    self.document_types.each do |d|
      votes[ d['document'] ] ||= 0
      votes[ d['document'] ] += 1
    end
    max_vote = votes.values.max
    votes.select{ |k,v| v == max_vote }
  end
  
  def users
    @users ||= self.classifications.map{|t|t.user_name}.uniq
  end
  
  def image
    self.location["standard"]
  end
  
  def group_name
    self.group["name"]
  end

end   