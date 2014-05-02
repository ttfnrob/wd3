class Timeline
  include MongoMapper::Document
  plugin GeoSpatial

  set_collection_name "war_diary_timelines"
  belongs_to :subject

  key :subject_id, ObjectId
  key :group, String
  key :page, String
  key :datetime, Time
  key :page_number, Integer
  geo_key :coords, Array

end