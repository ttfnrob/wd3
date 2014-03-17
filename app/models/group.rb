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
    @tags = []
    
    if @tags.empty?
      Subject.where('group.zooniverse_id' => self.zooniverse_id ).fields(:zooniverse_id).sort('metadata.page_number').all().each do |p|
        type = p.document_type.keys.join(',')
        @tags.push(*p.clusterize( n, threshold )) if type == 'diary'
      end
    end
    
    @tags
  end
  
  def completed
    completed = 100 * self.stats['complete'].to_f/self.stats['total'].to_f
    completed.round unless self.stats['total'].to_i == 0
  end
end