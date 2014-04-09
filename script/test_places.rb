place = ARGV[0] || 'Ypres'
fields = ['name', 'lat', 'long', 'id']
votes = {}

Tag.find_each( :type => 'place', :compare => place.upcase.gsub(/[^A-Z0-9]/, '') ) do |t|
  
  fields.each do |f|
    votes[f] ||= {}
    label = t['votes'][f]
    #label = 'none' if label == ''
    unless label == ['']
      votes[ f ][ label ] ||= 0
      votes[ f ][ label ] += 1
    end
  end
  
  puts t['label'], votes
  
end

votes.each do |k,v|
  max_vote = v.values.max
  votes[k] = v.select { |k, vote| vote == max_vote }
end

puts '***********'
puts votes