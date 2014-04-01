class Tag
  include MongoMapper::Document
  set_collection_name "war_diary_tags"
  belongs_to :subject

  key :id, ObjectId
  key :subject_id, ObjectId

end