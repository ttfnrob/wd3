class Discussion
  include MongoMapper::Document
  set_collection_name "discussions"

  key :project_id, ObjectId

end