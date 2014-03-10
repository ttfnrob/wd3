class Discussion
  include MongoMapper::Document
  set_collection_name "discussions"

  key :id, ObjectId
  key :project_id, ObjectId

end