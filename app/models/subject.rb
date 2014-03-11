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
      x = tag['coords'][0].to_i
      y = tag['coords'][1].to_i
      label = tag['label'] || ''
      max_y = y + n
      min_y = y - n
      max_x = x + 4 * n
      min_x = x - 4 * n
      
      set = []
      set << tag
      unless completed.include?(tag)
        set = tags.inject([]) do |set, t|
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
          clustered_tags << {"type" => tag['type'], "tag" => closest, "count" => tag_count, "hit_rate" => tag_count.to_f/user_count.to_f}
          set.each{|i| completed << i}
        elsif set.count > 0 && completed.include?(tag)==true
          #do nothing
        else  
          #Single tags still go in
          clustered_tags << {"type" => tag['type'], "tag" => tag, "count" => 1, "hit_rate" => 1.0/user_count}
          completed << tag
        end
      end
    end
    
    cleaned_tags = []
    initial_tag = {"type" => '', "tag" => {"compare" => ""}, "count" => 0, "hit_rate" => 0}
    clustered_tags.sort_by{|i| [i['tag']['coords'][1].to_i, i['tag']['coords'][0].to_i]}.inject(initial_tag) do |last_tag, tag|
      if tag["type"] == last_tag["type"] && tag["tag"]["compare"] == last_tag["tag"]["compare"]
        last_tag["count"] += tag["count"]
      else
        cleaned_tags << tag
      end
      tag
    end

    return cleaned_tags.reject{|tag| tag["count"] < threshold}
  end
 
  def tags
    @tags ||= self.classifications.map{|c|c.annotations}.flatten.select{|i|i["type"]}.sort_by{|i| [i['coords'][1], i['coords'][0]]}
    
    @tags.each do |tag|
      note = tag['note']
      case tag['type']
      when 'person'
        tag['label'] = "#{note['rank']} #{note['first']} #{note['surname']} #{note["reason"]}"
      when 'place'
        tag['label'] = note['place']
      when 'reference'
        tag['label'] = note['reference']
      when 'unit'
        tag['label'] = note['name']
      when 'casualties'
        labels = note.reject{|k,v| v.to_i == 0}.map{|k,v| "#{k}: #{v}"}
        tag['label'] = labels.empty? ? 'casualties: 0' : labels.join(', ')
      when 'gridRef'
        labels = note.reject{|k,v| v.to_i == ''}.values
        tag['label'] = labels.empty? ? '' : labels.join(' ')
      else
        tag['label'] = note.to_s
      end
      tag['label'].strip!
      tag['compare'] = tag['label'].upcase.gsub(/[^A-Z0-9]/, '')
    end
    
    @tags
  end
  
  def comments
    discussions = Discussion.where( :title => self.zooniverse_id ).first
    return discussions['comments'] unless discussions.nil?
    return []
  end
  
  def document_types
    @document_types ||= self.classifications.map{|c| c.annotations.select{|a| a['document']}}
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