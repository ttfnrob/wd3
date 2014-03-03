class Classification
  include MongoMapper::Document
  set_collection_name "war_diary_classifications"
  belongs_to :subject

  key :id, ObjectId
  key :workflow_id, ObjectId
  key :user_id, ObjectId, :optional
  key :user_name, String, :optional
  key :annotations, Array
  key :subjects, Array
  key :created_at, Date

  def subject_id
    subjects.first["id"]
  end

  def zooniverse_id
   self.subjects.first["zooniverse_id"]
  end

end