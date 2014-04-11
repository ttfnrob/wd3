class Place
  include MongoMapper::Document
  plugin GeoSpatial

  set_collection_name "war_diary_places"

  key :id, ObjectId
  key :label, String
  key :name, String
  key :compare, String
  key :geoid, Integer
  geo_key :coords, Array

end