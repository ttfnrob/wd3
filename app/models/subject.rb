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
  
  def classifications
    Classification.where(:subject_ids => [Subject.find_by_zooniverse_id(self.zooniverse_id).id])
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

end   