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

  def subject_id
    subjects.first["id"]
  end

  def zooniverse_id
   self.subjects.first["zooniverse_id"]
  end

end

total = MongoClassification.size
counter = 0
MongoClassification.each do |c|
	counter+=1
	puts "Processing classification #{counter} or #{total}" if counter%1000==0 && counter>1
	if c.try(:annotations)
		c.annotations.each do |a|
			# begin
				if a["type"]

					person = Person.create({
					  :x => a["coords"][0],
					  :y => a["coords"][1],
					  :page_id => c.zooniverse_id,
					  :user_id => c.user_name,
					  :first => a["note"]["first"],
					  :surname => a["note"]["surname"],
					  :rank => a["note"]["rank"],
					  :reason => a["note"]["reason"]
					}) if a["type"] == "person" && a["note"]

					place = Place.create({
					  :x => a["coords"][0],
					  :y => a["coords"][1],
					  :page_id => c.zooniverse_id,
					  :user_id => c.user_name,
					  :typed_name => a["note"]["place"],
					  :geocoded_name => a["note"]["name"],
					  :lat => a["note"]["lat"],
					  :lon => a["note"]["long"],
					  :at_location => a["note"]["location"]
					}) if a["type"] == "place" && a["note"]

					diary_date = DiaryDate.create({
					  :x => a["coords"][0],
					  :y => a["coords"][1],
					  :page_id => c.zooniverse_id,
					  :user_id => c.user_name,
					  :date => a["note"]
					}) if a["type"] == "diaryDate" && a["note"]

					activity = Activity.create({
					  :x => a["coords"][0],
					  :y => a["coords"][1],
					  :page_id => c.zooniverse_id,
					  :user_id => c.user_name,
					  :category => a["note"]
					}) if a["type"] == "activity" && a["note"]

					weather = Weather.create({
					  :x => a["coords"][0],
					  :y => a["coords"][1],
					  :page_id => c.zooniverse_id,
					  :user_id => c.user_name,
					  :category => a["note"]
					}) if a["type"] == "weather" && a["note"]

				end
			# rescue
			# 	puts "Error:"
			# 	puts a
			# end
		end
	end
end