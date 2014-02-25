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
  key :created_at, Date

  def subject_id
    subjects.first["id"]
  end

  def zooniverse_id
   self.subjects.first["zooniverse_id"]
  end

end

puts "Finding timestamp of most recently added annotations..."
most_recent_annotation = DiaryDate.count>0 ? DiaryDate.order("created_at").last.created_at : "2000-01-01 00:00:00"
most_recent_date = Time.parse(most_recent_annotation.to_s)

if most_recent_annotation==="2000-01-01 00:00:00"
	puts "...found no records - starting from scratch."
else
	puts "...found records up to #{most_recent_date} - picking up from there."
end

pending_classifications = MongoClassification.where(:created_at.gte => Time.parse(most_recent_date.to_s)).sort(:created_at.asc)
total = pending_classifications.size
puts "#{total} of #{MongoClassification.size} classifications to process. Go!"

counter = 0
pending_classifications.each do |c|
	counter+=1
	puts "Processed #{counter}/#{total} classifications" if counter%1000==0 && counter>1
	if c.try(:annotations)
		@started_at = c.annotations.select{|a| a["started_at"] if a["started_at"]}.first["started_at"]
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
					  :reason => a["note"]["reason"],
					  :created_at => @started_at
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
					  :at_location => a["note"]["location"],
					  :note => a["note"],
					  :created_at => @started_at
					}) if a["type"] == "place" && a["note"]

					diary_date = DiaryDate.create({
					  :x => a["coords"][0],
					  :y => a["coords"][1],
					  :page_id => c.zooniverse_id,
					  :user_id => c.user_name,
					  :date => a["note"],
					  :note => a["note"],
					  :created_at => @started_at
					}) if a["type"] == "diaryDate" && a["note"]

					activity = Activity.create({
					  :x => a["coords"][0],
					  :y => a["coords"][1],
					  :page_id => c.zooniverse_id,
					  :user_id => c.user_name,
					  :category => a["note"],
					  :created_at => @started_at
					}) if a["type"] == "activity" && a["note"]

					weather = Weather.create({
					  :x => a["coords"][0],
					  :y => a["coords"][1],
					  :page_id => c.zooniverse_id,
					  :user_id => c.user_name,
					  :category => a["note"],
					  :created_at => @started_at
					}) if a["type"] == "weather" && a["note"]

				end
			# rescue
			# 	puts "Error:"
			# 	puts a
			# end
		end
	end
end