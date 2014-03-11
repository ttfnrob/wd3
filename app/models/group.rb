class Group
  include MongoMapper::Document
  set_collection_name "war_diary_groups"
  
  key :id, ObjectId
  key :zooniverse_id, String
end