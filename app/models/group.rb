class Group
  include MongoMapper::Document
  set_collection_name "war_diary_groups"
  
  key :id, ObjectId
  key :zooniverse_id, String
  key :stats, Hash
  
  def pages
    @pages ||= Subject.where('group.zooniverse_id' => self.zooniverse_id ).fields(:zooniverse_id, :location).sort('metadata.page_number').limit(20)
  end
  
  def completed
    completed = 100 * self.stats['complete'].to_f/self.stats['total'].to_f
    completed.round unless self.stats['total'].to_i == 0
  end
end