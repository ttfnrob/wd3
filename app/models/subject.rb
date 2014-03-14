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
  
  def classifications
    @classifications ||= Classification.where(:subject_ids => [Subject.find_by_zooniverse_id(self.zooniverse_id).id])
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
  
  def clusterize(n=3, threshold = 1)
    clustered_tags = []
    completed = []
    user_count = self.users.count
  
    self.tags.each do |tag|
      
      unless completed.include?(tag)
        set = self.build_set(completed, tag, n)
        
        unless set.count == 0
          tag_count = set.size
          # Find averaged tag centre and select nearest real tag to that
          cx = set.map{|i| i['coords'][0].to_i}.inject{|sum,x| sum + x } / tag_count
          cy = set.map{|i| i['coords'][1].to_i}.inject{|sum,y| sum + y } / tag_count
          closest = set.sort_by{|i| (i['coords'][0].to_i-cx)**2 + (i['coords'][1].to_i-cy)**2}.reverse.first
          votes = {}
          case tag['type']
          when 'place'
            votes = self.gather_votes('location', set)
          when 'person'
            votes = self.gather_votes('reason', set)
          end
          
          # Add to set and record they are all done - i.e. don't duplicate process for tags in set
          clustered_tags << {"type" => tag['type'], "x" => cx, "y" => cy, "tag" => closest, "count" => tag_count, "hit_rate" => tag_count.to_f/user_count.to_f, "votes" => votes}
          set.each{|i| completed << i}
        end
      end
    end
    cleaned_tags = []
    initial_tag = {"type" => '', "tag" => {"compare" => ""}, "count" => 0, "hit_rate" => 0}
    clustered_tags.sort_by{|i| [i['y'], i['x']]}.inject(initial_tag) do |last_tag, tag|
      if tag["type"] == last_tag["type"] && tag["tag"]["compare"] == last_tag["tag"]["compare"]
        last_tag["count"] += tag["count"]
        votes = last_tag["votes"]
        last_tag['votes'] = votes.merge( tag['votes'] ){ |key, old, new| old + new }
      else
        cleaned_tags << tag
      end
      cleaned_tags.last
    end
    
    # decide on voted fields
    cleaned_tags.each do |t|
      votes = t['votes']
      max_vote = votes.values.max
      t['votes'] = votes.select { |k, v| v == max_vote }
    end

    return cleaned_tags.reject{|tag| tag["count"] < threshold}
  end
  
  def build_set(completed, tag, n)
    # all other tags of same type which are not completed yet.
    comparison = tags.reject{|t| t == tag || completed.include?(t) || t["type"] != tag["type"]}
    
    x = tag['coords'][0].to_i
    y = tag['coords'][1].to_i
    label = tag['label'] || ''
    max_y = y + n
    min_y = y - n
    max_x = x + 4 * n
    min_x = x - 4 * n
    
    set = []
    set << tag
    
    set = comparison.inject(set) do |set, t|
      tx = t['coords'][0].to_i
      ty = t['coords'][1].to_i
      tlabel = t['label'] || ''
      x_good = tx <= max_x && tx >= min_x
      y_good = ty <= max_y && ty >= min_y
      if t['type'] == 'diaryDate'
        t_date = tlabel.split(' ')
        tag_date = label.split(' ')
        good = y_good && t_date[0] == tag_date[0] && t_date[1] == tag_date[1]
      else
        good = x_good && y_good && t['compare'] == tag['compare']
      end
      set << t if good
      set
    end
  end
  
  def gather_votes(vote_field, set)
    votes = {}
    set.each do |t|
      votes[ t['note'][vote_field] ] ||= 0
      votes[ t['note'][vote_field] ] += 1
    end
    votes
  end
 
  def tags
    @tags ||= self.classifications.map{|c|c.annotations}.flatten.select{|i|i["type"]}.sort_by{|i| [i['coords'][1], i['coords'][0]]}
    
    @tags.each do |tag|
      note = tag['note']
      case tag['type']
      when 'person'
        tag['label'] = "#{note['rank']} #{note['first']} #{note['surname']}"
      when 'place'
        tag['label'] = "#{note['place']}"
      when 'reference'
        tag['label'] = note['reference']
      when 'unit'
        tag['label'] = note['name']
      when 'casualties'
        labels = note.reject{|k,v| v.to_i == 0}.map{|k,v| "#{k}: #{v}"}
        tag['label'] = labels.empty? ? 'casualties: 0' : labels.join(', ')
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
    end
    
    @tags.sort_by{|i| [i['coords'][1].to_i, i['coords'][0].to_i]}
  end
  
  def comments
    discussions = Discussion.where( :title => self.zooniverse_id ).first
    return discussions['comments'] unless discussions.nil?
    return []
  end
  
  def document_types
    @document_types ||= self.classifications.map{|c| c.annotations.select{|a| a['document']}}.flatten
  end
  
  def document_type
    votes = {}
    self.document_types.each do |d|
      puts d
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