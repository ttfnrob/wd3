counter = 0

Group.find_each( :state => 'complete' ) do |g|
  counter += 1
  puts "#{counter} #{g.zooniverse_id} #{g.name}"
  
  n = 5
  threshold = 2
  
  timeline = []
  
  Timeline.destroy_all( :group => g.zooniverse_id ) unless g.state == 'complete'
  
  Timeline.sort(:page_number).limit(1).find_each( :group => g.zooniverse_id ) do |t|
    timeline << t
  end
  
  if timeline.empty?
    g.tags n.to_i, threshold.to_i
    timeline = g.timeline
  end
end