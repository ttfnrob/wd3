require 'csv'
require 'mongo_mapper'

# connect to MongoDB
MongoMapper.connection = Mongo::Connection.new('localhost')
MongoMapper.database = 'war_diary'

class MongoSubject
  include MongoMapper::Document
  set_collection_name "war_diary_subjects"
 
  key :id, ObjectId
  key :workflow_ids, Array
  key :state, String
  key :location, Hash
  key :classification_count, Integer

  key :metadata, Hash
  key :size, String
  key :zooniverse_id, String
  
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

class MongoClassification
  include MongoMapper::Document
  set_collection_name "war_diary_classifications"
  belongs_to :subject

  key :id, ObjectId
  key :workflow_id, ObjectId
  key :user_id, ObjectId, :optional
  key :user_name, String, :optional
  key :annotations, Array
  key :subjects, Array

end

total = MongoSubject.size
counter = 0
MongoSubject.each do |s|
	counter+=1
	puts "Processing subject #{counter} or #{total}" if counter%1000==0 && counter>1
	person = Page.create({
	  :id => s.zooniverse_id,
	  :group_id => s.group_id,
	  :url => s.image,
	  :name => s.group_name,
	  :tna_id => s.tna_id,
	  :page_number => s.page_number
	}) if Page.where(:id => s.zooniverse_id).blank?
end