#  drop and rewrite the places collection from the tags collection.
fields = ['name', 'lat', 'long', 'id']
place_names = []
places = []
count = 0

Tag.fields( :label, :compare, :votes ).sort( :compare ).find_each( :type => 'place' ) do |p|
  count += 1
  places << {:label => p['label'], :compare => p['compare'], :votes => p['votes']} unless p['votes']['id'] == ''
  puts count
end

places.collect{|t| {:label => t[:label], :compare => t[:compare]}}.uniq.each do |p|
  place_names << p
end

puts place_names.length

count = 0
Place.destroy_all

place_names.each do |place|
  votes = {}
  puts place[:compare]
  
  places.select{|t| t[:compare] == place[:compare] }.each do |t|
  
    fields.each do |f|
      votes[f] ||= {}
      label = t[:votes][f]
      #label = 'none' if label == ''
      unless label == ['']
        votes[ f ][ label ] ||= 0
        votes[ f ][ label ] += 1
      end
    end
  
  end
  
  max_vote = 0

  votes.each do |k,v|
    max_vote = v.values.max
    votes[k] = v.select { |k, vote| vote == max_vote }
  end
  
  puts "Vote #{max_vote}"

  unless max_vote.nil? || max_vote < 3 || votes['name'].keys.length > 1
    p = {
      :label => place[:label],
      :compare => place[:compare],
      :name => votes['name'].keys.join(','),
      :coords => [votes['long'].keys.join(',').to_f, votes['lat'].keys.join(',').to_f],
      :geoid => votes['id'].keys.join(',').to_i
    }
    Place.new(p).save()
    count += 1
    puts "#{count} Created #{p}"
  end
  
end